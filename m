From: Frederic Leroy <fredo@starox.org>
Subject: Re: [PATCHv2 1/2] tcp: Stalling connections: Move timeout
 calculation routine
Date: Mon, 7 Dec 2009 13:01:01 +0100
Message-ID: <20091207130101.5dcbb949@houba>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de>
	<4B1C9D94.3070504@gmail.com>
	<4B1CE45A.9010908@tvk.rwth-aachen.de>
	<4B1CE9E7.5010400@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:46829 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934189AbZLGMBU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 07:01:20 -0500
In-Reply-To: <4B1CE9E7.5010400@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mon, 07 Dec 2009 12:41:27 +0100,
Damian Lukowski <damian@tvk.rwth-aachen.de> a =C3=A9crit :

> This patch moves retransmits_timed_out() from include/net/tcp.h
> to tcp_timer.c, where it is used.

I just finish to make .18 and .19 trace with your previous patch.
It's still available in http://www.starox.org/pub/scp_stall/

The copy was successful.
=2E18 is with your patch + some printk.
=2E19 is with your patch only.
I also checked that it still fails without.

Do you wan't me to make new trace with the new series of patch ?
I couldn't do it before this evening.

--=20
=46r=C3=A9d=C3=A9ric Leroy
