From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net-next tree
Date: Thu, 15 May 2014 16:47:03 +1000
Message-ID: <20140515164703.73a1cf06@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/h8m/DOTfu6s+AuTmazMByyL"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	WANG Cong <xiyou.wangcong@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/h8m/DOTfu6s+AuTmazMByyL
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
allnoconfig) produced this warning:


include/net/ip.h:211:5: warning: "CONFIG_SYSCTL" is not defined [-Wundef]
 #if CONFIG_SYSCTL
     ^

Introduced by commit 122ff243f5f1 ("ipv4: make ip_local_reserved_ports
per netns").
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/h8m/DOTfu6s+AuTmazMByyL
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTdGLrAAoJEMDTa8Ir7ZwV5dkP/1ZGvu+aLJW1Myyclf5nKEpw
ivlunv9MhTGWyvJzyFEneE8plDGsLeUU67iRwB7s1JJYmIBztFsDS5Sqme/0IwQT
X3G5mdg4gKZ+oZGYTPeFAkMoWJGvtNTXI1NdZ0Ca4liVNVoeFp+KPlDeh/68sFee
gYSpoZ68CUm3DJyKs2H+YLgZ/2IRb5fwvdcX5aLE/tTc8uEid/QQOC43O8Petz4k
kORV/f3QRgWB+JHi6Dnct4UAykEGvlCkp3EbcXKcoOYt7ynr2MBEg3epv1wdwQKI
pYcaM/kuW/gDdz5AT7TcywelPtfbYavUqEVrBbikRqiLrYWVToch9viLoNq/5u6B
VPT/YMj8cFQoisNQNyZbxwbdp8sbOY7CkApYs+jNRig3FnYe5b1SRqr7TEuXHexv
/3KlPapt4t4crXevdsS+LQ5XL8c6gS+6JrEWLO//wh2orY+fbslNojyW2rm3O+iz
RsiJvbPYO+MlLLncAKYIeVTxnTPDXRZoxncyERAUIqs3zYjMi3CLx/V45Z9+hKbH
6SuVYNXHpdktvzlfk027zW2szn59ypGebLjsSfuAX2BPfcR7/MCRzOgU8VJLhoYE
qJB29DX92r0BVif3gGK1Z/2tqZyPapafVHKCgWb7urLzqXWvUeJNnF/LqR6RAEvG
x4RddWFx2sxKXhP7GrWA
=1uaA
-----END PGP SIGNATURE-----

--Sig_/h8m/DOTfu6s+AuTmazMByyL--
