From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Fri, 9 Sep 2011 18:22:32 -0500
Message-ID: <CAKWjMd7pa=BikH0VkUZEFZ9yH+g6g9RSus9woqs1hbR+rb3u9A@mail.gmail.com>
References: <1314820906-14004-1-git-send-email-david.daney@cavium.com>
	<1314820906-14004-3-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: David Daney <david.daney@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314820906-14004-3-git-send-email-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 31, 2011 at 3:01 PM, David Daney <david.daney@cavium.com> w=
rote:
> This patch adds a somewhat generic framework for MDIO bus
> multiplexers. =A0It is modeled on the I2C multiplexer.
>
> The multiplexer is needed if there are multiple PHYs with the same
> address connected to the same MDIO bus adepter, or if there is
> insufficient electrical drive capability for all the connected PHY
> devices.
>
> Conceptually it could look something like this:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ------------------
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | Control Signal |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 --------+---------
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |
> =A0--------------- =A0 --------+------
> =A0| MDIO MASTER |---| Multiplexer |
> =A0--------------- =A0 --+-------+----
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 C =A0 =A0 =A0 C
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 h =A0 =A0 =A0 h
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i =A0 =A0 =A0 i
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l =A0 =A0 =A0 l
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 d =A0 =A0 =A0 d
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0 =A0 |
> =A0 =A0 --------- =A0 =A0 =A0 A =A0 =A0 =A0 B =A0 ---------
> =A0 =A0 | =A0 =A0 =A0 | =A0 =A0 =A0 | =A0 =A0 =A0 | =A0 | =A0 =A0 =A0=
 |
> =A0 =A0 | PHY@1 +-------+ =A0 =A0 =A0 +---+ PHY@1 |
> =A0 =A0 | =A0 =A0 =A0 | =A0 =A0 =A0 | =A0 =A0 =A0 | =A0 | =A0 =A0 =A0=
 |
> =A0 =A0 --------- =A0 =A0 =A0 | =A0 =A0 =A0 | =A0 ---------
> =A0 =A0 --------- =A0 =A0 =A0 | =A0 =A0 =A0 | =A0 ---------
> =A0 =A0 | =A0 =A0 =A0 | =A0 =A0 =A0 | =A0 =A0 =A0 | =A0 | =A0 =A0 =A0=
 |
> =A0 =A0 | PHY@2 +-------+ =A0 =A0 =A0 +---+ PHY@2 |
> =A0 =A0 | =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
 =A0 |
> =A0 =A0 --------- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ---------
>
> This framework configures the bus topology from device tree data. =A0=
The
> mechanics of switching the multiplexer is left to device specific
> drivers.
>
> The follow-on patch contains a multiplexer driven by GPIO lines.


It's amazing how various companies' board designers have come up with
the same brain-dead PHY topologies. We (Freescale) have some similar
code in our tree, but it's not this generically applicable.

>
> Signed-off-by: David Daney <david.daney@cavium.com>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: "David S. Miller" <davem@davemloft.net>

Looks good to me.

Acked-by: Andy Fleming <afleming@freescale.com>
