From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Device Tree Binding for Marvell DSA Switch on imx28 board over
 Mdio Interface
Date: Mon, 17 Nov 2014 14:45:02 -0200
Message-ID: <CAOMZO5Crue+NFEEkhzG3YYVQfq-Yu6s-+gZUyRQh3LawhbD8iQ@mail.gmail.com>
References: <CA+KjHfYZdZ88ZFzFCPN-bGphh+mnSWy6i0WNzFYv=gOsafXA7g@mail.gmail.com>
	<5463B2AC.6090904@gmail.com>
	<CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Oliver Graute <oliver.graute@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:51876 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbaKQQpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 11:45:04 -0500
Received: by mail-la0-f42.google.com with SMTP id s18so4783489lam.15
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 08:45:02 -0800 (PST)
In-Reply-To: <CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2014 at 1:15 PM, Oliver Graute <oliver.graute@gmail.com> wrote:


> mdio_bus: mdio@800f0040 {
>         #address-cells = <1>;
>         #size-cells = <0>;
>         device_type = "mdio";
>         //compatible = "fsl,gianfar-mdio";
>         compatible = "fsl,mpc875-fec-mdio", "fsl,pq1-fec-mdio";

These compatible strings are for PowerQuicc devices, not for mx28.

>         reg = <0x800f0040 0x188>;
>         status = "okay";
>
>          ethphy0: ethernet-phy@0 {
>                 compatible = "fsl,gianfar-mdio";

Same here.
