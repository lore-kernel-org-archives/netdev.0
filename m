From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH] mv643xx_eth: convert to use the Marvell Orion MDIO
 driver
Date: Thu, 14 Mar 2013 16:36:37 -0400
Message-ID: <20130314203637.GX12700@titan.lakedaemon.net>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org>
 <1363284515-9865-1-git-send-email-florian@openwrt.org>
 <1363284515-9865-2-git-send-email-florian@openwrt.org>
 <20130314190235.GW12700@titan.lakedaemon.net>
 <514225E9.9060902@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	linux-doc@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Rob Herring <rob.herring@calxeda.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	linux-arm-kernel@lists.infradead.org,
	Rob Landley <rob@landley.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <514225E9.9060902@openwrt.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 14, 2013 at 08:32:57PM +0100, Florian Fainelli wrote:
> Hello Jason,
>=20
> Le 14/03/2013 20:02, Jason Cooper a =E9crit :
> >Florian,
> >
> >On Thu, Mar 14, 2013 at 07:08:32PM +0100, Florian Fainelli wrote:
> >>This patch converts the Marvell MV643XX ethernet driver to use the
> >>Marvell Orion MDIO driver. As a result, PowerPC and ARM platforms
> >>registering the Marvell MV643XX ethernet driver are also updated to
> >>register a Marvell Orion MDIO driver. This driver voluntarily overl=
aps
> >>with the Marvell Ethernet shared registers because it will use a su=
bset
> >>of this shared register (shared_base + 0x4 - shared_base + 0x84). T=
he
> >>Ethernet driver is also updated to look up for a PHY device using t=
he
> >>Orion MDIO bus driver.
> >>
> >>Signed-off-by: Florian Fainelli <florian@openwrt.org>
> >>---
> >>  arch/arm/plat-orion/common.c               |   97 +++++++++++----
> >>  arch/powerpc/platforms/chrp/pegasos_eth.c  |   20 +++
> >>  arch/powerpc/sysdev/mv64x60_dev.c          |   14 ++-
> >>  drivers/net/ethernet/marvell/Kconfig       |    1 +
> >>  drivers/net/ethernet/marvell/mv643xx_eth.c |  186 ++-------------=
-------------
> >>  include/linux/mv643xx_eth.h                |    1 -
> >>  6 files changed, 117 insertions(+), 202 deletions(-)
> >
> >Isn't this the old version of 4/4 ?
>=20
> No this really is v2, but I reformatted just that one and sent it
> without the v2 changelog, you should have received the proper
> version a couple minutes later once I realized my mistake.

Yes, I received both, just making sure.

thx,

Jason.
