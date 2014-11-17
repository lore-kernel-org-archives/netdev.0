From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Device Tree Binding for Marvell DSA Switch on imx28 board over
 Mdio Interface
Date: Mon, 17 Nov 2014 17:09:34 +0100
Message-ID: <20141117160934.GR2001@lunn.ch>
References: <CA+KjHfYZdZ88ZFzFCPN-bGphh+mnSWy6i0WNzFYv=gOsafXA7g@mail.gmail.com>
 <5463B2AC.6090904@gmail.com>
 <CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>
 <54650E9C.7080708@gmail.com>
 <CA+KjHfZSeM=CPxbpoTAjbC3S5EKw+M59hii3t2zY4HePmFGZYg@mail.gmail.com>
 <CA+KjHfa=Tqs=CWe6TT+rbmc9UaFZghqW1OtigPm9wOyXgN2AOQ@mail.gmail.com>
 <CA+KjHfY13ynH4Zr5Cerhswo3eucj3DMwq0tZ5CQquT3yuxKv-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>, buytenh@wantstofly.org
To: Oliver Graute <oliver.graute@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33833 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625AbaKQQJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 11:09:57 -0500
Content-Disposition: inline
In-Reply-To: <CA+KjHfY13ynH4Zr5Cerhswo3eucj3DMwq0tZ5CQquT3yuxKv-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> dsa@0 {
>         compatible = "marvell,dsa";
>         #address-cells = <2>;
>         #size-cells = <0>;
> 
>         interrupts = <10>;
>         //dsa,ethernet = <&ethphy1>;
>         //dsa,ethernet = <&eth1>;
>         dsa,ethernet = <&mac1>;
>         //dsa,ethernet = <&mac0>;
>         dsa,mii-bus = <&mdio_bus>;
> 
>         switch@0 {
>             #address-cells = <1>;
>             #size-cells = <0>;
>             reg = <5 0>;   /* MDIO address 5, switch 0 in tree */

Hi Oliver

How do you have the strapping pins on the switch set? They determine
what address on the mdio bus the chip responds to.

Does your u-boot have commands to read arbitrary phy registers?
Generally, reading a register that does not exist gives 0xffff.  So
try some reads at different addresses and see what you can find.

    Andrew
