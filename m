From: =?UTF-8?B?QW5kcsOp?= Roth <neolynx@gmail.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Sun, 13 Nov 2016 20:13:39 +0100
Message-ID: <20161113201339.667ac1f7@gmail.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
        <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
        <CAFBinCC0HiEXx5mELztH6jYfUq2f1u0Tb+pSzAvwQSu9vYydGQ@mail.gmail.com>
        <20161031112524.4c4ee8f8@gmail.com>
        <1478192276.6632.34.camel@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Johnson Leung <r58129@freescale.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        linux-amlogic@lists.infradead.org,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org
To: Jerome Brunet <jbrunet@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35432 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935021AbcKMTNn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 14:13:43 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so9924105wme.2
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 11:13:43 -0800 (PST)
In-Reply-To: <1478192276.6632.34.camel@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Andre, the 3.14 kernel you are talking, is it this one ? :=C2=A0
> https://github.com/hardkernel/linux/tree/odroidc2-3.14.y

yes
=20
> Because in drivers/net/phy/realtek.c, they disable EEE, but
> also=C2=A01000Base-T Full Duplex advertisement ?
>=20
> +	/* disable 1000m adv*/
> +	val =3D phy_read(phydev, 0x9);
> +	phy_write(phydev, 0x9, val&(~(1<<9)));
>=20
> If this is the kernel you are running, you should not be able to have
> ethernet at 1000MB/s ? Or is it in half duplex mode ?

ethtool shows 1000Mb/s Full-Duplex and the bandwith is around 300Mb/s
(as measured by scp). kernel version: 3.14.65-73
