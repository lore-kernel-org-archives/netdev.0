From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rx_dropped packets stop with tcpdump running
Date: Thu, 19 Apr 2012 15:28:08 +0200
Message-ID: <1334842088.2395.178.camel@edumazet-glaptop>
References: <DUB108-W3E0658169335663BE7574B23D0@phx.gbl>
	 <1334841865.2395.177.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56927 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449Ab2DSN2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 09:28:13 -0400
Received: by bkcik5 with SMTP id ik5so6357066bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 06:28:12 -0700 (PDT)
In-Reply-To: <1334841865.2395.177.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 15:24 +0200, Eric Dumazet wrote:

> When linux receives a packet with no protocol handler, we increment the
> rx_dropped counter.
> 
> When you start a tcpdump, all packets are handled, so we dont increment
> rx_dropped for this reason anymore.
> 
> 

Its done since 2.6.37 (commit caf586e5)
