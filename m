From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v5 2/8] dpaa_eth: add support for DPAA Ethernet
Date: Fri, 04 Dec 2015 12:00:35 -0800
Message-ID: <1449259235.8611.19.camel@perches.com>
References: <1449150589-26253-1-git-send-email-madalin.bucur@freescale.com>
	 <1449150589-26253-3-git-send-email-madalin.bucur@freescale.com>
	 <20151204.145549.859527220803940077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, scottwood@freescale.com,
	igal.liberman@freescale.com, ppc@mindchasers.com,
	pebolle@tiscali.nl, joakim.tjernlund@transmode.se,
	gregkh@linuxfoundation.org
To: David Miller <davem@davemloft.net>, madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151204.145549.859527220803940077.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-12-04 at 14:55 -0500, David Miller wrote:
> From: Madalin Bucur <madalin.bucur@freescale.com>
> Date: Thu, 3 Dec 2015 15:49:43 +0200
>=20
> > @@ -0,0 +1,22 @@
> > +menuconfig FSL_DPAA_ETH
> > +=A0=A0=A0=A0=A0tristate "DPAA Ethernet"
> > +=A0=A0=A0=A0=A0depends on FSL_SOC && FSL_BMAN && FSL_QMAN && FSL_F=
MAN
> > +=A0=A0=A0=A0=A0select PHYLIB
> > +=A0=A0=A0=A0=A0select FSL_FMAN_MAC
>=20
> I do not see the FSL_FMAN_MAC Kconfig symbol defined anywhere in the
> tree.

I believe this patch series is dependent on two
other patch series mentioned in the cover letter.
---
The latest FMan driver patches were submitted by Igal Liberman:
https://patchwork.ozlabs.org/project/netdev/list/?submitter=3D64715&sta=
te=3D*

The latest Q/BMan drivers were submitted by Roy Pledge:
https://patchwork.ozlabs.org/project/linuxppc-dev/list/?submitter=3D663=
31&state=3D*
