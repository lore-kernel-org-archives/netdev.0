From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: Query regarding PTP_1588_CLOCK
Date: Mon, 15 Apr 2013 14:16:18 -0400
Message-ID: <38549.1366049778@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1366049778_1938P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1366049778_1938P
Content-Type: text/plain; charset=us-ascii

In drivers/net/ethernet/intel/Kconfig, we see this:

config E1000E
        tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
        depends on PCI && (!SPARC32 || BROKEN)
        select CRC32
        select PTP_1588_CLOCK
        ---help---

Is there a reason for the PTP_1588_CLOCK select?  That ends up
forcing the PTP and PPS stuff into the kernel as well - and I don't
use any of it.

--==_Exmh_1366049778_1938P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUWxD8gdmEQWDXROgAQKq1xAAmLe0QfUekYMrFcWoneDF7abtrWp8lIfE
iUvhwMO5jxsSsc0hI7MQCTbngJMZSnSjj+OkDBHSh46ExiJbcH4cqr0xuBQqPv/3
jhu2ktAADpgcfOWrm8Tqq2F925yDBZuzNoVmoH+YFbNyglvVCWCVFM/YIcBSid2N
BXDypWTMjObjAx1BjEUZupWa7SBBF4tNLeY9Fo078Dq/gCOVJ+lK55BEyUtIlN9L
1dc8JMgwl/nkCxPB1BIBcTaK8xJ33DQ90AbPKc5xj/thqhGw565Z+LNomvN+h+jr
zJh9IVgCTOJdfYxciDL18LKVaMkKFrykIXvjFH+Z5DBtlqm1ys+OLGNIgbFYFymg
wpEzjgBempFyXE0SbjgCnt/4he0fUCO1yEgsFkAKjPev8u3osYu/irHSxvgsYAoV
w/Il5p59tq0k/ZMii6iIgcR3ET4HWrWx/UKQPsrmXoDqIgDoXQzwFtdZTlDSjD/x
0YF4opTIbcdNXZmuwkYeQkx8lo7FAaB1k3AZjU05g6DFUCt9f4YxldibkXGpNaX/
LUZSPEYRfIlCZUTAw9OX8DSbsPYxhdXMv4WVAH2dXAMv848sYF1yHkvmmZOxNWq1
W7Ny8wJXY4NIE9H/PdsDYZFW/qCbHOZiPPjNGPN3vefMr63jKAkA1AWozci7+vRK
v80RboZWDuY=
=lqFq
-----END PGP SIGNATURE-----

--==_Exmh_1366049778_1938P--
