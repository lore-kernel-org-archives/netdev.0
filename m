From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 11:24:56 +0200
Message-ID: <1334049896.3126.23.camel@edumazet-glaptop>
References: <4F83EB0E.4020104@monstr.eu>
	 <1334046444.3126.12.camel@edumazet-glaptop>
	 <1334046746.3126.13.camel@edumazet-glaptop>  <4F83F166.4010208@monstr.eu>
	 <1334047544.3126.14.camel@edumazet-glaptop>  <4F83F959.3070302@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47672 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915Ab2DJJZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 05:25:02 -0400
Received: by bkcik5 with SMTP id ik5so4005019bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 02:25:00 -0700 (PDT)
In-Reply-To: <4F83F959.3070302@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 11:11 +0200, Michal Simek wrote:

> ~ # cat /proc/sys/net/ipv4/tcp_rmem
> 4096    87380   130048

Are they default values, or tuned by admin ?

130048 bytes isnt enough to let TCP open its rcv window.
