From: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
Subject: [PATCH 0/3] crypto/chcr: Add Chelsio Crypto Driver
Date: Mon, 11 Jul 2016 11:28:05 -0700
Message-ID: <1468261688-24525-1-git-send-email-yeshaswi@chelsio.com>
Cc: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, linux-crypto@vger.kernel.org,
	jlulla@chelsio.com, atul.gupta@chelsio.com, harsh@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

This patch series contains 3 patches that add support for Chelsio's
Crypto Hardware.

The patch series has been created against Herbert Xu's tree (crypto-2.6).
It includes patches for Chelsio Low Level Driver(cxgb4) and adds the new
crypto Upper Layer Driver(chcr) under a new directory drivers/crypto/chelsio.

The first of the patch series implements necessary changes in the Chelsio
LLD for queue allocation, deallocation and registration of the ULD.

The second patch implements the Chelsio crypto driver.

The third patch contains the changes to the driver/crypto/Kconfig and
drivers/crypto/Makefile to enable the Chelsio Crypto driver.

We have included all the maintainers of respective drivers. Kindly
review the changes and provide feedback on the same.

Yeshaswi M R Gowda (3):
  cxgb4: Add Chelsio LLD support Chelsio Crypto ULD
  chcr: Support for Chelsio's Crypto Hardware
  crypto: Added Chelsio Menu to the Kconfig file

 drivers/crypto/Kconfig                          |    2 +
 drivers/crypto/Makefile                         |    1 +
 drivers/crypto/chelsio/Kconfig                  |   19 +
 drivers/crypto/chelsio/Makefile                 |    4 +
 drivers/crypto/chelsio/chcr_algo.c              | 1531 +++++++++++++++++++++++
 drivers/crypto/chelsio/chcr_algo.h              |  502 ++++++++
 drivers/crypto/chelsio/chcr_core.c              |  273 ++++
 drivers/crypto/chelsio/chcr_core.h              |   85 ++
 drivers/crypto/chelsio/chcr_crypto.h            |  255 ++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   22 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   71 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   10 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   64 +
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |  437 +++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  125 ++
 15 files changed, 3393 insertions(+), 8 deletions(-)
 create mode 100644 drivers/crypto/chelsio/Kconfig
 create mode 100644 drivers/crypto/chelsio/Makefile
 create mode 100644 drivers/crypto/chelsio/chcr_algo.c
 create mode 100644 drivers/crypto/chelsio/chcr_algo.h
 create mode 100644 drivers/crypto/chelsio/chcr_core.c
 create mode 100644 drivers/crypto/chelsio/chcr_core.h
 create mode 100644 drivers/crypto/chelsio/chcr_crypto.h

-- 
1.7.10.1
