From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/4] nfc: Logging updates
Date: Tue, 29 Nov 2011 11:37:31 -0800
Message-ID: <cover.1322595343.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the standard logging styles

Joe Perches (4):
  nfc: Use standard logging styles
  nfc: Convert nfc_dbg to pr_debug
  nfc: Remove unused nfc_printk and nfc_<level> macros
  nfc: Remove function tracer like entry messages

 net/nfc/core.c     |   60 +++++++++++++-----------------------
 net/nfc/nci/core.c |   84 +++++++++++++++++++++------------------------------
 net/nfc/nci/data.c |   30 ++++++++++--------
 net/nfc/nci/ntf.c  |   83 ++++++++++++++++++++++++++-------------------------
 net/nfc/nci/rsp.c  |   84 ++++++++++++++++++++++++++-------------------------
 net/nfc/netlink.c  |   32 ++------------------
 net/nfc/nfc.h      |    7 ----
 net/nfc/rawsock.c  |   28 +++++++++--------
 8 files changed, 176 insertions(+), 232 deletions(-)

-- 
1.7.6.405.gc1be0
