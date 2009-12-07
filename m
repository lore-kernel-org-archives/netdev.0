From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Fix for stalling connections
Date: Mon, 07 Dec 2009 03:22:43 -0800 (PST)
Message-ID: <20091207.032243.62632219.davem@davemloft.net>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de>
	<4B1C9D94.3070504@gmail.com>
	<4B1CE45A.9010908@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, fredo@starox.org,
	herbert@gondor.apana.org.au, gregkh@suse.de
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56858
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933740AbZLGLWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 06:22:43 -0500
In-Reply-To: <4B1CE45A.9010908@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Mon, 07 Dec 2009 12:17:46 +0100

> Eric Dumazet schrieb:
>> You should a hint of faulty commit so that stable team can apply
>> this patch to 2.6.32 & 2.6.31
>> 
>> git describe 6fa12c85031485dff38ce550c24f10da23b0adaa
>> 
>> v2.6.31-rc5-1853-g6fa12c8
> 
> It has been introduced with retransmits_timed_out() in 2.6.32,
> as timeout calculations have based on the number of
> retransmissions before. The patch is needed for 2.6.32
> and 2.6.33, but 2.6.31 does not use retransmits_timed_out().

I think also the commit introducing the regression should be
explicitly referenced in the commit message of the fix.

>> Or maybe David handles this for us, I dont know...
>> 
>> Minor note : retransmits_timed_out() is used in from net/ipv4/tcp_timer.c
>> I wonder why its a "static inline" in include/net/tcp.h
> 
> I can place it in tcp_timer.c, if it's that, what you mean.

I'm pretty sure that's what he means :-)
