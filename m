From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/3] nfc: standardize logging styles
Date: Fri,  5 Apr 2013 12:27:36 -0700
Message-ID: <cover.1365189658.git.joe@perches.com>
References: <1365180413.2075.5.camel@joe-AO722>
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	linux-wireless@vger.kernel.org, linux-nfc@lists.01.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365180413.2075.5.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix some defects in the logging too

Joe Perches (3):
  nfc: Replace nfc_dev_dbg with dev_dbg, remove function tracing
  nfc: Convert nfc_dev_info and nfc_dev_err to nfc_<level>
  nfc: Standardize logging style

 drivers/nfc/microread/i2c.c       |  32 ++---
 drivers/nfc/microread/mei.c       |  20 +--
 drivers/nfc/microread/microread.c |   7 +-
 drivers/nfc/nfcwilink.c           |  95 ++++++-------
 drivers/nfc/pn533.c               | 271 ++++++++++++++++----------------------
 drivers/nfc/pn544/i2c.c           |  38 +++---
 drivers/nfc/pn544/pn544.c         |  13 +-
 include/net/nfc/nfc.h             |   5 +-
 8 files changed, 196 insertions(+), 285 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
