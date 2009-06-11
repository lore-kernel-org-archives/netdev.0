From: Subrata Modak <subrata@linux.vnet.ibm.com>
Subject: Re: [PATCH] Re:[BUILD FAILURE 04/04] Next June 04:PPC64 randconfig
	[drivers/net/ucc_geth.o]
Date: Thu, 11 Jun 2009 07:26:04 +0530
Message-ID: <1244685364.6494.14.camel@subratamodak.linux.ibm.com>
References: <20090610174323.28045.70169.sendpatchset@subratamodak.linux.ibm.com>
	 <20090611110523.1fd56a41.sfr@canb.auug.org.au>
Reply-To: subrata@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090611110523.1fd56a41.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-06-11 at 11:05 +1000, Stephen Rothwell wrote:
> Hi Subrata,
>=20
> On Wed, 10 Jun 2009 23:13:23 +0530 Subrata Modak <subrata@linux.vnet.=
ibm.com> wrote:
> >
> >  	/* Find the TBI PHY.  If it's not there, we don't support SGMII *=
/
> > -	ph =3D of_get_property(np, "tbi-handle", NULL);
> > +	ph =3D (phandle *)of_get_property(np, "tbi-handle", NULL);
>=20
> You don't need this cast because of_get_property() returns "void *".

Stephen,

True. But without this gcc complains:

CC [M]  drivers/net/ucc_geth.o
drivers/net/ucc_geth.c: In function =E2=80=98ucc_geth_probe=E2=80=99:
drivers/net/ucc_geth.c:3824: warning: assignment discards qualifiers
from pointer target type

Else gcc just builds fine:

CC [M]  drivers/net/ucc_geth.o

This is an just an extra caution to fix both the build and warning
regression(s).

Regards--
Subrata

>=20
