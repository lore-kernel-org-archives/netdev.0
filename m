From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCHv2 1/2] tcp: Stalling connections: Move timeout calculation
 routine
Date: Mon, 07 Dec 2009 17:11:39 +0100
Message-ID: <op.u4kslpdnp498uc@nexus>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de> <4B1C9D94.3070504@gmail.com>
 <4B1CE45A.9010908@tvk.rwth-aachen.de> <4B1CE9E7.5010400@tvk.rwth-aachen.de>
 <20091207130101.5dcbb949@houba>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	=?utf-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:39264 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932496AbZLGQLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 11:11:40 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUA00EQ0IBMWD20@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 07 Dec 2009 17:11:46 +0100 (CET)
In-reply-to: <20091207130101.5dcbb949@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 07.12.2009, 13:01 Uhr, schrieb Frederic Leroy <fredo@starox.org>:

> Le Mon, 07 Dec 2009 12:41:27 +0100,
> Damian Lukowski <damian@tvk.rwth-aachen.de> a =C3=A9crit :
>
>> This patch moves retransmits_timed_out() from include/net/tcp.h
>> to tcp_timer.c, where it is used.
>
> I just finish to make .18 and .19 trace with your previous patch.
> It's still available in http://www.starox.org/pub/scp_stall/
>
> The copy was successful.
> .18 is with your patch + some printk.
> .19 is with your patch only.
> I also checked that it still fails without.
>
> Do you wan't me to make new trace with the new series of patch ?
> I couldn't do it before this evening.

Hi,
you could test v3 if it is acked at least by Ilpo. But since v3
leads to the same code as v2, it think it will be fine.

Thank you.

Damian
