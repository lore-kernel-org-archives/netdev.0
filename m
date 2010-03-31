From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] Allow MACB to connect to a higher addresses PHY.
Date: Wed, 31 Mar 2010 00:08:28 -0600
Message-ID: <x2gfa686aa41003302308r8c4f84acy5ab0c7368313aa5@mail.gmail.com>
References: <1269943112-6975-1-git-send-email-anders.darander@gmail.com>
	<fa686aa41003300741x5ef9bdbpf56133304fe4d6e6@mail.gmail.com>
	<20100331055306.GC4837@datarespons.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>,
	Maxime Bizon <mbizon@freebox.fr>,
	David Daney <ddaney@caviumnetworks.com>,
	Sekhar Nori <nsekhar@ti.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Anders Darander <anders.darander@datarespons.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100331055306.GC4837@datarespons.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2010 at 11:53 PM, Anders Darander
<anders.darander@datarespons.se> wrote:
> * Grant Likely <grant.likely@secretlab.ca> [100330 16:42]:
> One question, if I add such an kernel parameter, would it be OK to
> implement something like this in the macb-driver:
>
> if parameter =3D=3D SOME_DEFAULT
> =A0 =A0 =A0 =A0phydev =3D phy_find_first(bp->mii_bus);
> else
> =A0 =A0 =A0 =A0phydev =3D bp->mii_bus->phy_map[parameter];
>
> I.e. if the parameter is set to some default value, the old behaviour=
 is
> retained, otherwise the specified parameter is used for the phy_addr?

Absolutely.

g.
