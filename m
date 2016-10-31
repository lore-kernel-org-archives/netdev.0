From: =?UTF-8?B?QW5kcsOp?= Roth <neolynx@gmail.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Mon, 31 Oct 2016 11:25:24 +0100
Message-ID: <20161031112524.4c4ee8f8@gmail.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
        <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
        <CAFBinCC0HiEXx5mELztH6jYfUq2f1u0Tb+pSzAvwQSu9vYydGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Johnson Leung <r58129@freescale.com>, netdev@vger.kernel.org,
        Alexandre Torgue <alexandre.torgue@st.com>,
        linux-amlogic@lists.infradead.org
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37739 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757545AbcJaKZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 06:25:28 -0400
Received: by mail-wm0-f45.google.com with SMTP id t79so40666265wmt.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 03:25:28 -0700 (PDT)
In-Reply-To: <CAFBinCC0HiEXx5mELztH6jYfUq2f1u0Tb+pSzAvwQSu9vYydGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,
=20
> on my device this results in:
> [0xc9410018] =3D 0x2000000
> [0xc9410030] =3D 0x0
> [0xc941003c] =3D 0x0
> [0xc9411000] =3D 0x1100802
> [0xc9411018] =3D 0x2202006
> [0xc9411028] =3D 0x0
>=20
> maybe someone else could try the command from above on his device
> (running the original Amlogic kernel).

those registers have the same value on an original image from
hardkernel:=20

Linux odroid64 3.14.65-65 #1 SMP PREEMPT Sat May 28
02:50:51 BRT 2016 aarch64 aarch64 aarch64 GNU/Linux

> please also state if ethernet is working properly on the original
> kernel (and preferably which device/board this is).

yes, the ethernet works flawless in 100 and 1000 Mbit/s on the 3.14
kernel.

I can now confirm that both 100 and 1000 Mbit/s do not work properly
on the 4.8/integ branch. the network connection is interrupted after
some outbound traffic. it can be recovered by running a ifdown/ifup
which restarts dhclient, which I think is able to somehow reset the
interface.=20

Anything I can help to debug the issue further ?

Regards,

 Andr=C3=A9
=20
