From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Fri, 30 Jan 2009 23:41:23 +0100
Message-ID: <49838213.90700@cosmosbay.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kenny Chang <kchang@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38504 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbZA3Woh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:44:37 -0500
In-Reply-To: <49837F56.2020502@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kenny Chang a =E9crit :
> Ah, sorry, here's the test program attached.
>=20
> We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or the
> 2.6.29.-rcX.
>=20
> Right now, we are trying to step through the kernel versions until we
> see where the performance drops significantly.  We'll try 2.6.29-rc s=
oon
> and post the result.

2.6.29-rc contains UDP receive improvements (lockless)

Problem is multicast handling was not yet updated, but could be :)


I was asking you "cat /proc/interrupts" because I believe you might
have a problem NIC interrupts being handled by one CPU only (when havin=
g problems)


