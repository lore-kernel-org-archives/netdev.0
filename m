From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCHv3 2/6] net: Add MDIO bus driver for the Allwinner EMAC
Date: Fri, 24 May 2013 10:42:30 +0100
Message-ID: <CAGVrzcbyXiKCKxtOAj0gnG8eCQag8_xvmd9dUKACCbfW-2HN9Q@mail.gmail.com>
References: <1369387394-9453-1-git-send-email-maxime.ripard@free-electrons.com>
 <1369387394-9453-3-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Stefan Roese <sr@denx.de>,
	Emilio Lopez <emilio@elopez.com.ar>, kevin@allwinnertech.com,
	sunny@allwinnertech.com, shuge@allwinnertech.com
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369387394-9453-3-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Maxime,

2013/5/24 Maxime Ripard <maxime.ripard@free-electrons.com>
>
> This patch adds a separate driver for the MDIO interface of the
> Allwinner ethernet controllers.
>
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
> ---
>  .../bindings/net/allwinner,sun4i-mdio.txt          |  26 +++
>  drivers/net/ethernet/allwinner/Kconfig             |   8 +
>  drivers/net/ethernet/allwinner/Makefile            |   1 +
>  drivers/net/ethernet/allwinner/sun4i-mdio.c        | 191 +++++++++++++++++++++

Ok, so you probably followed Thomas's example here with mvneta/mvmdio,
but all other MDIO bus drivers live in drivers/net/phy. Unfortunately,
mvmdio lives in drivers/net/ethernet/marvell/mvmdio.c which I should
have noticed before. Whatever is good for you guys, but we should
probably start normalizing this now before more mdio drivers get
merged alongside their corresponding ethernet MAC users.
