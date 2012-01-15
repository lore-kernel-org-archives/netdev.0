From: "Anatoly Sivov" <mm05@mail.ru>
Subject: Re: why does skb->tstamp use getnstimeofday?
Date: Sun, 15 Jan 2012 23:55:23 +0400
Message-ID: <op.v745mll4fzo5me@stalin>
References: <op.v74shh18fzo5me@stalin>
 <1326645750.5287.48.camel@edumazet-laptop> <op.v74z14g2fzo5me@stalin>
 <1326653813.5287.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp24.mail.ru ([94.100.176.177]:55902 "EHLO smtp24.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778Ab2AOTyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 14:54:25 -0500
In-Reply-To: <1326653813.5287.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> TCP stack doesnt use skb->tstamp/jtime_t, for example, but jiffies.
Some CA engines asks for RTT calculation with skb->tstamp.
They state about it by setting TCP_CONG_RTT_STAMP flag in their struct  
tcp_congestion_ops instances.

> For what kind of application or protocol do you feel there could be a
> problem ?
I don't insist on problems are here, just want to mark that there could be  
a problem with these CA engines
in the case of "big ntp adjustment".
