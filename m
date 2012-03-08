From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH 0/7] powerpc: remove the legacy iSeries platform specific
 drivers
Date: Thu, 8 Mar 2012 15:28:53 +1100
Message-ID: <20120308152853.b5010336abbb8f90e8a2500c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__8_Mar_2012_15_28_53_+1100_FAEEpVFrow/u5bwP"
Cc: ppc-dev <linuxppc-dev@lists.ozlabs.org>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	<netdev@vger.kernel.org>, Alan Cox <alan@linux.intel.com>,
	Brian King <brking@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
	Jens Axboe <axboe@kernel.dk>,
	LKML <linux-kernel@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-serial-owner@vger.kernel.org>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__8_Mar_2012_15_28_53_+1100_FAEEpVFrow/u5bwP
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

This series of patches removes all the legacy iSeries platform specific
drivers (and the iSeries specific part of one).  The legacy iSeries
platform main code has already bee removed along with CONFIG_PPC_ISERIES,
so none of this code is selectable or needed any more.

It would probably be easiest if all these patches were merged via the
powerpc tree to eliminate any dependencies between them.  Their impact on
generic code is very small.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

 arch/powerpc/include/asm/iseries/hv_call_event.h |  201 ---
 arch/powerpc/include/asm/iseries/hv_lp_event.h   |  162 --
 arch/powerpc/include/asm/iseries/iommu.h         |   37 -
 arch/powerpc/include/asm/iseries/vio.h           |  265 ----
 arch/powerpc/kernel/vio.c                        |   18 +-
 drivers/base/driver.c                            |   30 -
 drivers/block/viodasd.c                          |  809 ----------
 drivers/cdrom/viocd.c                            |  739 ----------
 drivers/char/viotape.c                           | 1041 -------------
 drivers/net/ethernet/ibm/Kconfig                 |    4 -
 drivers/net/ethernet/ibm/Makefile                |    1 -
 drivers/net/ethernet/ibm/iseries_veth.c          | 1710 ------------------=
----
 drivers/scsi/Kconfig                             |    3 +-
 drivers/scsi/ibmvscsi/Makefile                   |    1 -
 drivers/scsi/ibmvscsi/ibmvscsi.c                 |   12 +-
 drivers/scsi/ibmvscsi/ibmvscsi.h                 |    1 -
 drivers/scsi/ibmvscsi/iseries_vscsi.c            |  173 ---
 drivers/tty/hvc/Kconfig                          |   10 -
 drivers/tty/hvc/Makefile                         |    1 -
 drivers/tty/hvc/hvc_iseries.c                    |  599 --------
 drivers/tty/serial/Kconfig                       |    2 +-
 include/linux/device.h                           |    4 -
 22 files changed, 5 insertions(+), 5818 deletions(-)

--Signature=_Thu__8_Mar_2012_15_28_53_+1100_FAEEpVFrow/u5bwP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPWDWFAAoJEECxmPOUX5FEbBAP/ibeDxIYy4XOacIv4XHMxS6w
1w4/Ubt50Mn/iXAcumqfQZPcbWjuIhmsfozJ71v12svc4XyGAvyfabnmyYdFtsaz
/jFUmB2RHYeMh1qbpMRvhV4UDws5g63w/IRbuFNIMOLf4SptuUsGLIWD/AIamFeO
OiEel64pSbrUY1ZihHDunnSA0Pl9riE0uvfMtmlFiF7Fdvum9VP6PLGKQssjFya4
//B4D4U1yWj5mw/a6oUY4HAuartCDXRKI5m9/lFdbkaWBjxneAez0ogynEYY2tqT
IIfPbRO64DVMZPEae4hg+h4o1MAu+HP+0UFOKazSh2oN9BJjAs3UZjqBPNQz3969
xZvH2TtTEkNu8qBu55/FZ9awutBWNESAnvhh1kAVal6pNmL998KOLht/LDzywacl
jPNSxOnv+6bCPvTFHW3j2MLDKslSfZkb40SyWamvm0Pp/uSqBSf6L+3DEpYg9VRH
MHXGaX9B8YFqkHEARCsw31v+SMoB9+RQtag5mzqQWYEouC+2VjUp1KFFQ+ltqWxX
wozF7KGZD5pIZKqtJMH6k/2Ju5rfOflzhqEwaBDSi1457fPAdRB4TK0RcoxujMpx
Ez9ahrKk03qRrDv1xSHX1Szzs3jj7X4RfEVbhmPLeVcIlz6puNpI53vB5dXTYK42
HkNbjPVfY4LyHm1bmGd6
=1lw0
-----END PGP SIGNATURE-----

--Signature=_Thu__8_Mar_2012_15_28_53_+1100_FAEEpVFrow/u5bwP--
