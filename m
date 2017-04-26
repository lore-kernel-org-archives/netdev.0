From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/2] ARM: dts: Add the ethernet and ethernet PHY to
 the cygnus core DT.
Date: Wed, 26 Apr 2017 02:49:07 +0200
Message-ID: <20170426004907.GA9453@lunn.ch>
References: <20170425235357.7690-1-eric@anholt.net>
 <20170425235357.7690-2-eric@anholt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>
To: Eric Anholt <eric@anholt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41238 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1432605AbdDZAtY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 20:49:24 -0400
Content-Disposition: inline
In-Reply-To: <20170425235357.7690-2-eric@anholt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +		eth0: ethernet@18042000 {
> +			compatible = "brcm,amac";
> +			reg = <0x18042000 0x1000>,
> +			      <0x18110000 0x1000>;
> +			reg-names = "amac_base", "idm_base";
> +			interrupts = <GIC_SPI 110 IRQ_TYPE_LEVEL_HIGH>;
> +			max-speed = <1000>;

Hi Eric

Sorry i missed this the first time. Does this Ethernet controller do >
1Gbps? Does this max-speed do anything useful?

       Andrew
