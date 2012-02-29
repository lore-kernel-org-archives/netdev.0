From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: [PATCH] net: add QCA alx Ethernet driver
Date: Tue, 28 Feb 2012 17:50:09 -0800
Message-ID: <1330480210-30470-1-git-send-email-rodrigue@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	<kgiori@qca.qualcomm.com>, <chris.snook@gmail.com>,
	<mathieu@qca.qualcomm.com>, <bryanh@quicinc.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <mcgrof@frijolero.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luis R. Rodriguez <mcgrof@frijolero.org>

The next patch adds the new QCA alx Ethernet driver that
supercedes the atl1c Ethernet driver. For details please
read the commit log of the patch. Given the size you can
download the patch from:

http://bombadil.infradead.org/~mcgrof/2012/02/28/add-alx-next-20120228.patch
sha1sum: 8a8f7b6f1cbe737e70ec3b3eda483a6925fd9bd6

Many thanks to our QCA Networking engineering team for their hard
work on getting this driver polished, well tested against atl1c,
and also to Joe and Hao-Ran for their patches.

If you'd like to quickly install this on any system even with older
kernels you can get this tarball which has the driver backported
for older kernels:

http://www.orbit-lab.org/kernel/compat-wireless/2012/02/compat-wireless-2012-02-28-p.tar.bz2
sha1sum: 7c083fc568900fbeefed021d009620830f866819

The "-p" postfix annotates that we have applied a patch in this tarball
from the linux-next-pending/ directory. For more details see:

http://wireless.kernel.org/en/users/Download/stable/#Additional_patches_to_stable_releases

To only compile and install the alx driver you can do:

./scripts/driver-select alx
make
sudo make install

The install will disable atl1c in preference for alx. To revert back
to atl1c you can simply do:

./scripts/alx-enable atl1c

This is part of today's release of compat-wireless with the following
code metrics:

compat-wireless code metrics

    828230 - Total upstream lines of code being pulled
      2492 - backport code changes
      2137 - backport code additions
       355 - backport code deletions
      9015 - backport from compat module
     11507 - total backport code
    1.3893 - % of code consists of backport work
     13428 - Code changes posted but not yet merged
     13407 - Code additions posted but not yet merged
        21 - Code deletions posted but not yet merged
    1.6213 - % of code not yet merged

Base tree: linux-next.git
Base tree version: next-20120228
compat-wireless release: compat-wireless-2012-02-28-p

Luis R. Rodriguez (1):
  alx: add new QCA ethernet driver which supercedes atl1c

 MAINTAINERS                                    |   11 +
 drivers/net/ethernet/atheros/Kconfig           |   42 +-
 drivers/net/ethernet/atheros/Makefile          |    1 +
 drivers/net/ethernet/atheros/alx/Makefile      |    3 +
 drivers/net/ethernet/atheros/alx/alc_cb.c      |  912 ++++++
 drivers/net/ethernet/atheros/alx/alc_hw.c      | 1087 +++++++
 drivers/net/ethernet/atheros/alx/alc_hw.h      | 1324 ++++++++
 drivers/net/ethernet/atheros/alx/alf_cb.c      | 1187 +++++++
 drivers/net/ethernet/atheros/alx/alf_hw.c      |  918 ++++++
 drivers/net/ethernet/atheros/alx/alf_hw.h      | 2098 +++++++++++++
 drivers/net/ethernet/atheros/alx/alx.h         |  670 ++++
 drivers/net/ethernet/atheros/alx/alx_ethtool.c |  519 ++++
 drivers/net/ethernet/atheros/alx/alx_hwcom.h   |  187 ++
 drivers/net/ethernet/atheros/alx/alx_main.c    | 3899 ++++++++++++++++++++++++
 drivers/net/ethernet/atheros/alx/alx_sw.h      |  493 +++
 15 files changed, 13350 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/atheros/alx/Makefile
 create mode 100644 drivers/net/ethernet/atheros/alx/alc_cb.c
 create mode 100644 drivers/net/ethernet/atheros/alx/alc_hw.c
 create mode 100644 drivers/net/ethernet/atheros/alx/alc_hw.h
 create mode 100644 drivers/net/ethernet/atheros/alx/alf_cb.c
 create mode 100644 drivers/net/ethernet/atheros/alx/alf_hw.c
 create mode 100644 drivers/net/ethernet/atheros/alx/alf_hw.h
 create mode 100644 drivers/net/ethernet/atheros/alx/alx.h
 create mode 100644 drivers/net/ethernet/atheros/alx/alx_ethtool.c
 create mode 100644 drivers/net/ethernet/atheros/alx/alx_hwcom.h
 create mode 100644 drivers/net/ethernet/atheros/alx/alx_main.c
 create mode 100644 drivers/net/ethernet/atheros/alx/alx_sw.h

-- 
1.7.4.15.g7811d
