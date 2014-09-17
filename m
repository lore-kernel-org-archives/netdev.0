From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 17 Sep 2014 11:12:17 +1000
Message-ID: <20140917111217.36853551@canb.auug.org.au>
References: <20140917110454.399a7841@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/O8w4w6IJ9pTIu+K193PDvy3"; protocol="application/pgp-signature"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anish Bhatt <anish@chelsio.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140917110454.399a7841@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/O8w4w6IJ9pTIu+K193PDvy3
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Steffen,

On Wed, 17 Sep 2014 11:04:54 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> After merging the net tree, today's linux-next build (powerpc ppc64_defco=
nfig)
> failed like this:
>=20
> warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EIGER=
 && 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII whi=
ch has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX &&=
 440GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which ha=
s unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) selects=
 IBM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNET &=
& NET_VENDOR_IBM)
> warning: (LIBFC && SCSI_IBMVFC && SCSI_QLA_FC && SCSI_LPFC && ZFCP && SCS=
I_BFA_FC && SCSI_CHELSIO_FCOE && FUSION_FC) selects SCSI_FC_ATTRS which has=
 unmet direct dependencies (SCSI && NET)
> warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 440S=
Pe && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which has=
 unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> warning: (LIBFC && SCSI_IBMVFC && SCSI_QLA_FC && SCSI_LPFC && ZFCP && SCS=
I_BFA_FC && SCSI_CHELSIO_FCOE && FUSION_FC) selects SCSI_FC_ATTRS which has=
 unmet direct dependencies (SCSI && NET)
> warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX &&=
 440GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which ha=
s unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EIGER=
 && 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII whi=
ch has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) selects=
 IBM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNET &=
& NET_VENDOR_IBM)
> warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 440S=
Pe && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which has=
 unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_event':
> drivers/scsi/scsi_transport_fc.c:543:7: error: 'scsi_nl_sock' undeclared =
(first use in this function)
>   if (!scsi_nl_sock) {
>        ^
> drivers/scsi/scsi_transport_fc.c:543:7: note: each undeclared identifier =
is reported only once for each function it appears in
> drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_vendor_event':
> drivers/scsi/scsi_transport_fc.c:611:7: error: 'scsi_nl_sock' undeclared =
(first use in this function)
>   if (!scsi_nl_sock) {
>        ^
>=20
> This is a bit different to yesterday's failure but I assume it is still
> related to commit 5d6be6a5d486 ("scsi_netlink : Make SCSI_NETLINK
> dependent on NET instead of selecting NET").
>=20
> I used the net tree from next-20140915 again today.

I also had to use the version of the ipsec tree from next-20140916
since today's version is based on the version of the net tree with
errors.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/O8w4w6IJ9pTIu+K193PDvy3
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUGN/1AAoJEMDTa8Ir7ZwVO6MP/iGgU5TAlLvxUcCUh87RetoV
KPftcMl8oXSOeWa8Aj5OROXG9XmJVRngYiXwqc4zBoq53R16VjvZ5TX8tMvL5tmA
n8ivWVvcXDZUa0cEkGKXWVN8hTABVwSeqa6Tghb3Su2it0eUoJcsd3QfIehH7++u
JuZEK9drpEd7RxIs43JyVv4M4ruUkZALJdv3lGVxcc9+4C6593PXYHgyDdyWpccL
iJKrwG9ZWROvbvblIJm8QpQfMW39QnbauOIGYxd2euaqzHl21IJQTG/0nHRHqBlb
sVGeCoQiylDaHV62P+obczCeKju609vGihWtRWJHKd/TxEvPc89DL+iuhmvShcBC
nwS7abRbdteyPBJ5ckynJvUMR+h/zmWf3QVStcoeJHiiNJ6ca1vt3vNx87f92SM7
L/q/IpvLIKL9hzv+YiCY1n38uiRTGfF/ZdPCgUtd0y7BzoIrV+ge+CAqWoTv4lA6
I3WqPhLEVhHCrdBo6iKfze/E3ffEYurxTwrPacULsfNYAQ+QkB4Zpt5jthnQ6qNI
ezamy7fnqYbx/mulx3aGxejVaOJ36kp09Lbi0tr08y29mi6CH38cIMZQdDUmpIS4
KCj70sSqlO63GmXVyOKCG0em99WvJX+dBoCqez4yvknBfG98KOFgyGJ7hwLf8udv
xONtczTIh+5VHeZF34w6
=aCFo
-----END PGP SIGNATURE-----

--Sig_/O8w4w6IJ9pTIu+K193PDvy3--
