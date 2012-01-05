From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bug in qavg calculation in include/net/red.h (resending as
 plain-text email)
Date: Thu, 05 Jan 2012 21:13:20 +0100
Message-ID: <1325794400.2748.1.camel@edumazet-laptop>
References: <67E2BF19E6D6A749A7680AEF496EB37C39D9204067@GVW0547EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Yalagandula, Praveen" <praveen.yalagandula@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46393 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758287Ab2AEUN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 15:13:26 -0500
Received: by werm1 with SMTP id m1so659667wer.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 12:13:25 -0800 (PST)
In-Reply-To: <67E2BF19E6D6A749A7680AEF496EB37C39D9204067@GVW0547EXC.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 19:30 +0000, Yalagandula, Praveen a =C3=
=A9crit :
> (Resending as plain text)
>=20
> Dear Alexey,
>=20
> The code (see below) for computing the queue average for RED
> implementation in Linux kernel has a bug. The return line should be
> "return p->qavg + ((backlog - p->qavg) >> p->Wlog);".=20
>=20
> qavg =3D qavg*(1-W) + backlog*W
>=20
>      =3D qavg + (backlog-qavg)*W
>=20
> The current buggy code applies right shift to only the previous qavg,
> where as it should be applied to (backlog - qavg). Hope you can get
> this bug corrected.

Code is correct.

Please read the comment, it really explains the thing.

Thanks
