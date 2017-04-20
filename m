From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v6 3/4] net: dsa: LAN9303: add I2C managed mode support
Date: Thu, 20 Apr 2017 11:04:22 -0500
Message-ID: <20170420160422.ypqmrexunklhjtqu@rob-hp-laptop>
References: <20170418084827.19613-1-jbe@pengutronix.de>
 <20170418084827.19613-4-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
        devicetree@vger.kernel.org, mark.rutland@arm.com
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170418084827.19613-4-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 18, 2017 at 10:48:26AM +0200, Juergen Borleis wrote:
> In this mode the switch device and the internal phys will be managed via
> I2C interface. The MDIO interface is still supported, but for the
> (emulated) CPU port only.
> 
> Signed-off-by: Juergen Borleis <jbe@pengutronix.de>
> CC: devicetree@vger.kernel.org
> CC: robh+dt@kernel.org
> CC: mark.rutland@arm.com
> ---
>  .../devicetree/bindings/net/dsa/lan9303.txt        |  62 +++++++++++

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/net/dsa/Kconfig                            |  16 +++
>  drivers/net/dsa/Makefile                           |   2 +
>  drivers/net/dsa/lan9303_i2c.c                      | 113 +++++++++++++++++++++
>  4 files changed, 193 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/lan9303.txt
>  create mode 100644 drivers/net/dsa/lan9303_i2c.c
