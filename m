From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Wed, 24 Sep 2014 10:36:11 +1000
Message-ID: <20140924103611.07175304@canb.auug.org.au>
References: <20140918103200.12b79941@canb.auug.org.au>
	<541A28BA.1060201@infradead.org>
	<54218AEF.5090200@suse.cz>
	<20140924072306.799005a3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/I0ZNQyCAKnGr0nx9fMn+nL."; protocol="application/pgp-signature"
Cc: Randy Dunlap <rdunlap@infradead.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-kbuild <linux-kbuild@vger.kernel.org>,
	Linus <torvalds@linux-foundation.org>
To: Michal Marek <mmarek@suse.cz>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20140924072306.799005a3@canb.auug.org.au>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/I0ZNQyCAKnGr0nx9fMn+nL.
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Wed, 24 Sep 2014 07:23:06 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> On Tue, 23 Sep 2014 16:59:59 +0200 Michal Marek <mmarek@suse.cz> wrote:
> >
> > On 2014-09-18 02:35, Randy Dunlap wrote:
> > > On 09/17/14 17:32, Stephen Rothwell wrote:
> > >> Hi all,
> > >>
> > >> After merging the net tree, today's linux-next build (powerpc
> > >> ppc64_defconfig) produced these warnings:
> > >>
> > >> warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && =
EIGER && 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMI=
I which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR=
_IBM)
> > >> warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440E=
PX && 440GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII whi=
ch has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> > >> warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) se=
lects IBM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHER=
NET && NET_VENDOR_IBM)
> > >> warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX &&=
 440SPe && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 whic=
h has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> > >> warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440E=
PX && 440GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII whi=
ch has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> > >> warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && =
EIGER && 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMI=
I which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR=
_IBM)
> > >> warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) se=
lects IBM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHER=
NET && NET_VENDOR_IBM)
> > >> warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX &&=
 440SPe && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 whic=
h has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> > >>
> > >=20
> > > I have looked into these and don't see why there is a problem.
> > > Any help would be appreciated.
> >=20
> > This is a side effect of 5d6be6a5 ("scsi_netlink : Make SCSI_NETLINK
> > dependent on NET instead of selecting NET"). Previously, SCSI_FC_ATTRS
> > would select SCSI_NETLINK which would select CONFIG_NET. The above
> > warnings are just a tip of the iceberg, the more serious issue is that
> > ppc64_defconfig is lacking networking support. This is the downside of
> > savedefconfig, because the 'select' implications can disappear over
> > time. Looks like more defconfigs are affected by this:
>=20
> And since 5d6be6a5 is now in Linus' tree, we need Michal's 5 patches
> (at least) to be sent to Linus ASAP ...

I have put those 5 patches in my fixes tree for today ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/I0ZNQyCAKnGr0nx9fMn+nL.
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUIhH/AAoJEMDTa8Ir7ZwVdN0P/RsKOOMt/CI12FFkY2iBBPC1
zDfTguPVGBLyUeE7mjrR9//J1j/4DYPFyHsAOrIR5JjKs8tHObbNCrMGOD3PX82G
crPmGZVqlYWvNsjwetOLNKL2TAJB4SQtwEaglQWhKT7aqcNgUNngKCf8J9cwaKFK
AKniLCEIuDuLFDgvqXd1bYmzQBO1dxP7QvE5s4Ay4O9DwhCZPChDqCPc2iRKDtVK
VCXjMMGATM2i0Wp9aeddWM8gctDLv8VY08ghP8WDKfiJ2REI0ZHS6BIih+OpdJs9
zAFJnEDDWMAQWzUZ334IFaZFf6HG4L29lm+Vd2dJNCVMTR1/dwc8UytZdi6Eezb/
iCbCtkTVGycSywvIOp3w9CwDp6mxTcVXJ669K3HOsOMp+7Kjn2Ib3uIRvzcLT6A9
ufQQiejZMkcmo6BpVry18JgLIByethmzLkC0Vc+AXXGm6AEOzr1ay68UHhs3PSGv
N6EHOFEbphAHRXfpoOOYekkGlYge4G5DJWsn7os1A4Mu2JrOYbJ4AclGRr1Wi1wG
DmYtR9lRm5QaOMRYx4Nej/F+UQ30xkIudfYJNbQaKXz0rlU0ZgaKcowgi4RTocdg
ftcWh9/CHERPNO8E1TgNmlXf6PUNFhgdhxafZMcW3G1WePrIN7FvTwWlBximsq7u
IfqcWhqBTg6QMRvzmBYs
=cn1z
-----END PGP SIGNATURE-----

--Sig_/I0ZNQyCAKnGr0nx9fMn+nL.--
