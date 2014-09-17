From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Wed, 17 Sep 2014 11:04:54 +1000
Message-ID: <20140917110454.399a7841@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/zx=4EZDC=iQqMnuJaLKP/RQ"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anish Bhatt <anish@chelsio.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/zx=4EZDC=iQqMnuJaLKP/RQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (powerpc ppc64_defconf=
ig)
failed like this:

warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EIGER &=
& 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII which=
 has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX && 4=
40GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which has =
unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) selects I=
BM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNET && =
NET_VENDOR_IBM)
warning: (LIBFC && SCSI_IBMVFC && SCSI_QLA_FC && SCSI_LPFC && ZFCP && SCSI_=
BFA_FC && SCSI_CHELSIO_FCOE && FUSION_FC) selects SCSI_FC_ATTRS which has u=
nmet direct dependencies (SCSI && NET)
warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 440SPe=
 && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which has u=
nmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (LIBFC && SCSI_IBMVFC && SCSI_QLA_FC && SCSI_LPFC && ZFCP && SCSI_=
BFA_FC && SCSI_CHELSIO_FCOE && FUSION_FC) selects SCSI_FC_ATTRS which has u=
nmet direct dependencies (SCSI && NET)
warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX && 4=
40GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which has =
unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EIGER &=
& 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII which=
 has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) selects I=
BM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNET && =
NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 440SPe=
 && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which has u=
nmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_event':
drivers/scsi/scsi_transport_fc.c:543:7: error: 'scsi_nl_sock' undeclared (f=
irst use in this function)
  if (!scsi_nl_sock) {
       ^
drivers/scsi/scsi_transport_fc.c:543:7: note: each undeclared identifier is=
 reported only once for each function it appears in
drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_vendor_event':
drivers/scsi/scsi_transport_fc.c:611:7: error: 'scsi_nl_sock' undeclared (f=
irst use in this function)
  if (!scsi_nl_sock) {
       ^

This is a bit different to yesterday's failure but I assume it is still
related to commit 5d6be6a5d486 ("scsi_netlink : Make SCSI_NETLINK
dependent on NET instead of selecting NET").

I used the net tree from next-20140915 again today.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/zx=4EZDC=iQqMnuJaLKP/RQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUGN5BAAoJEMDTa8Ir7ZwVs9AP/3CUdAa8BmdQDdkkoVbdoXsk
40X/dl/60zmZWes14vLjFWlVwFGb0OF6QNpJn4ApA9yAL52vnMdVHB4Lil9iJfGQ
NI8vdu1WaG/UrercogpbXf+2TKoofKA+UBUxYTB/bkH0w5l6AmZ4pecZg+f9Jhvf
aasq/99WKd70uvWaQaig6mrbzyIq18zCfvIH5RnLag+R6qFzDcEtAwg98qnuSoOx
fe/wI+tAg4vgP79jmLb+lmbezCiXqc4Xa+RvVDHxpBkVWCAQw1w/74E6ErEtNDtV
8c3cJYKC0Q3DnFU1pJcezUa5rvXzSzHtmGXEf3ikfwgGaeQge406uf988/cDg4qD
Qhl1BA99SPsng78baMNLPMTQor3hVLKSA4AX913p/TgaYneJOXntd/etI2SmCBT2
dgZ4W3TKWpywxLlsG9mStWVm6nN+m4kuryvm4Ki2bS9qzon4AJcebLYvifve6YeZ
r5AXooIW7nAFXrqDw0xuEliQCguRsN0cHmdOK2M5EGqB5lHMThBLHS13Rfu+2Fpb
kEK+qYse0g6F20ub+edlYucljReY+9xT/VYF4ss1/snVdBIe8SzBxdCSRPdViRIp
CUO5PQS4urFc385RQfYOQN8trbDpYgcynxsK4B4aG5kUTEKaMIo9pTUVLA86phTw
bmww7ECKL2/L2oD2ySN0
=aTww
-----END PGP SIGNATURE-----

--Sig_/zx=4EZDC=iQqMnuJaLKP/RQ--
