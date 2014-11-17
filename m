From: Oliver Graute <oliver.graute@gmail.com>
Subject: Re: Device Tree Binding for Marvell DSA Switch on imx28 board over
 Mdio Interface
Date: Mon, 17 Nov 2014 17:54:01 +0100
Message-ID: <CA+KjHfaKhQL6J3FZjZrs-eh3URBL5geDWV9adpcvo-6SU-9aRg@mail.gmail.com>
References: <CA+KjHfYZdZ88ZFzFCPN-bGphh+mnSWy6i0WNzFYv=gOsafXA7g@mail.gmail.com>
	<5463B2AC.6090904@gmail.com>
	<CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>
	<CAOMZO5Crue+NFEEkhzG3YYVQfq-Yu6s-+gZUyRQh3LawhbD8iQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:53809 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbaKQQyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 11:54:03 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so5436299ier.0
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 08:54:02 -0800 (PST)
In-Reply-To: <CAOMZO5Crue+NFEEkhzG3YYVQfq-Yu6s-+gZUyRQh3LawhbD8iQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Fabio,

and what's the correct one for the imx28 CPU?

Best Regards,

Oliver


On Mon, Nov 17, 2014 at 5:45 PM, Fabio Estevam <festevam@gmail.com> wrote:
> On Thu, Nov 13, 2014 at 1:15 PM, Oliver Graute <oliver.graute@gmail.com> wrote:
>
>
>> mdio_bus: mdio@800f0040 {
>>         #address-cells = <1>;
>>         #size-cells = <0>;
>>         device_type = "mdio";
>>         //compatible = "fsl,gianfar-mdio";
>>         compatible = "fsl,mpc875-fec-mdio", "fsl,pq1-fec-mdio";
>
> These compatible strings are for PowerQuicc devices, not for mx28.
>
>>         reg = <0x800f0040 0x188>;
>>         status = "okay";
>>
>>          ethphy0: ethernet-phy@0 {
>>                 compatible = "fsl,gianfar-mdio";
>
> Same here.
