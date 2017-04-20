From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v6 4/4] net: dsa: LAN9303: add MDIO managed mode support
Date: Thu, 20 Apr 2017 11:06:07 -0500
Message-ID: <20170420160607.kf7bdrlmwrle4ghy@rob-hp-laptop>
References: <20170418084827.19613-1-jbe@pengutronix.de>
 <20170418084827.19613-5-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
        devicetree@vger.kernel.org, mark.rutland@arm.com, sr@denx.de
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170418084827.19613-5-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 18, 2017 at 10:48:27AM +0200, Juergen Borleis wrote:
> When the LAN9303 device is in MDIO manged mode, all register accesses must
> be done via MDIO.
> 
> Please note: this code is compile time tested only due to the absence of such
> configured hardware. It is based on a patch from Stefan Roese from 2014.
> 
> Signed-off-by: Juergen Borleis <jbe@pengutronix.de>
> CC: devicetree@vger.kernel.org
> CC: robh+dt@kernel.org
> CC: mark.rutland@arm.com
> CC: sr@denx.de
> ---
>  .../devicetree/bindings/net/dsa/lan9303.txt        |  45 ++++++-

I'd prefer to see the full binding in one separate patch.

Otherwise, looks fine to me.

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/net/dsa/Kconfig                            |   8 ++
>  drivers/net/dsa/Makefile                           |   1 +
>  drivers/net/dsa/lan9303_mdio.c                     | 148 +++++++++++++++++++++
>  4 files changed, 201 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/net/dsa/lan9303_mdio.c
