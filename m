From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Mon, 07 Dec 2009 13:53:29 -0500
Message-ID: <4B1D4F29.8020309@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig60DE440AFE06F18CF3FEB625"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758704AbZLGSxa@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig60DE440AFE06F18CF3FEB625
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Linus,

Please pull AlacrityVM guest support for 2.6.33 from:

git://git.kernel.org/pub/scm/linux/kernel/git/ghaskins/alacrityvm/linux-2=
=2E6.git
for-linus

All of these patches have stewed in linux-next for quite a while now:

Gregory Haskins (26):
      shm-signal: shared-memory signals
      ioq: Add basic definitions for a shared-memory, lockless queue
      vbus: add a "vbus-proxy" bus model for vbus_driver objects
      vbus-proxy: add a pci-to-vbus bridge
      ioq: add driver-side vbus helpers
      net: add vbus_enet driver
      venet: Update maintainer
      venet: fix gso.hdr_len to report correct length
      venet: add pre-mapped tx descriptor feature
      venet: report actual used descriptor size
      venet: cache the ringlen values at init
      venet: add eventq protocol
      venet: use an skblist for outstanding descriptors
      venet: add a tx-complete event for out-of-order support
      venet: add Layer-4 Reassembler Offload (L4RO) support
      vbus: allow shmsignals to be named
      vbus: register shm-signal events as standard Linux IRQ vectors
      net: fix vbus-enet Kconfig dependencies
      venet: fix locking issue with dev_kfree_skb()
      vbus: fix kmalloc() from interrupt context to use GFP_ATOMIC
      fix irq resource leak
      vbus: remove create_irq() references from the pcibridge
      vbus: make library code properly declared as GPL
      venet: add missing ethtool include
      vbus: add autoprobe capability to guest
      vbus: fix pcibridge busmaster support

Jaswinder Singh Rajput (1):
      ioq: includecheck fix

Patrick Mullaney (1):
      vbus-enet: fix l4ro pool non-atomic allocations in softirq context

Rakib Mullick (1):
      vbus: Fix section mismatch warnings in pci-bridge.c

Randy Dunlap (2):
      vbus-proxy also uses ioq, so it should select IOQ.
      Eliminate all cast warnings in vbus-enet.c and pci-bridge.c.

Thadeu Lima de Souza Cascardo (1):
      trivial: fix a typo in SHM_SIGNAL config description

 MAINTAINERS                 |   25 +
 arch/x86/Kconfig            |    2 +
 drivers/Makefile            |    1 +
 drivers/net/Kconfig         |   14 +
 drivers/net/Makefile        |    1 +
 drivers/net/vbus-enet.c     | 1560
+++++++++++++++++++++++++++++++++++++++++++
 drivers/vbus/Kconfig        |   25 +
 drivers/vbus/Makefile       |    6 +
 drivers/vbus/bus-proxy.c    |  247 +++++++
 drivers/vbus/pci-bridge.c   | 1015 ++++++++++++++++++++++++++++
 include/linux/Kbuild        |    4 +
 include/linux/ioq.h         |  414 ++++++++++++
 include/linux/shm_signal.h  |  189 ++++++
 include/linux/vbus_driver.h |   83 +++
 include/linux/vbus_pci.h    |  145 ++++
 include/linux/venet.h       |  133 ++++
 lib/Kconfig                 |   21 +
 lib/Makefile                |    2 +
 lib/ioq.c                   |  300 +++++++++
 lib/shm_signal.c            |  196 ++++++
 20 files changed, 4383 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/vbus-enet.c
 create mode 100644 drivers/vbus/Kconfig
 create mode 100644 drivers/vbus/Makefile
 create mode 100644 drivers/vbus/bus-proxy.c
 create mode 100644 drivers/vbus/pci-bridge.c
 create mode 100644 include/linux/ioq.h
 create mode 100644 include/linux/shm_signal.h
 create mode 100644 include/linux/vbus_driver.h
 create mode 100644 include/linux/vbus_pci.h
 create mode 100644 include/linux/venet.h
 create mode 100644 lib/ioq.c
 create mode 100644 lib/shm_signal.c


--------------enig60DE440AFE06F18CF3FEB625
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksdTykACgkQP5K2CMvXmqEMgwCeNEOmsfPP3FiDa1oBtXJq+XkZ
krMAn09WC3h6hnXuVxmLA1ftoQ8SElju
=jjgY
-----END PGP SIGNATURE-----

--------------enig60DE440AFE06F18CF3FEB625--
