From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rx_dropped packets stop with tcpdump running
Date: Thu, 19 Apr 2012 15:24:25 +0200
Message-ID: <1334841865.2395.177.camel@edumazet-glaptop>
References: <DUB108-W3E0658169335663BE7574B23D0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38856 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639Ab2DSNYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 09:24:32 -0400
Received: by bkcik5 with SMTP id ik5so6353621bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 06:24:31 -0700 (PDT)
In-Reply-To: <DUB108-W3E0658169335663BE7574B23D0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 15:12 +0200, Marco Berizzi wrote:
> Hi Folks,
> 
> I'm running linux 3.3.2 on slackware64
> 13.1 as a firewall and ipsec gateway.
> I'm experimenting a problem on one of
> the nics: I see the rx_dropped packets
> counter increasing. Running tcpdump on
> that nic (eth2) 'fix' the problem: the
> counter doesn't increase anymore.
> The only remarkable running daemon is
> openswan 2.4.15
> 
> Same problem happens with linux 2.6.37
> 
> The connection is at 1000Mbit/s copper,
> full duplex.
> 
> Any feedback are welcome
> TIA

When linux receives a packet with no protocol handler, we increment the
rx_dropped counter.

When you start a tcpdump, all packets are handled, so we dont increment
rx_dropped for this reason anymore.
