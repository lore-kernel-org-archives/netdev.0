From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 0/5] drivers/isdn: fix sparse warnings
Date: Thu, 26 Feb 2009 00:08:20 +0100
Message-ID: <20090225230737.5377.31370.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761559AbZBYXIp@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series fixes some sparse warnings in drivers/isdn.

---

Hannes Eder (5):
      drivers/isdn/hardware/eicon: fix sparse warnings: Should it be static?
      drivers/isdn/hardware/icon: fix sparse warning: cast truncates bits
      drivers/isdn/hisax: fix sparse warning: Should it be static?
      drivers/isdn/act2000: fix sparse warning: symbol shadows an earlier one
      drivers/isdn/capi: fix sparse warning: context imbalance


 drivers/isdn/act2000/act2000_isa.c    |    6 +--
 drivers/isdn/capi/kcapi_proc.c        |    2 +
 drivers/isdn/hardware/eicon/debug.c   |    2 -
 drivers/isdn/hardware/eicon/message.c |   70 ++++++++++++++++++++++-----------
 drivers/isdn/hisax/callc.c            |    1 
 drivers/isdn/hisax/config.c           |    6 ---
 drivers/isdn/hisax/hfcscard.c         |    2 -
 drivers/isdn/hisax/hisax.h            |    9 ++++
 drivers/isdn/hisax/isdnl1.c           |    4 +-
 drivers/isdn/hisax/sedlbauer.c        |    2 -
 drivers/isdn/hisax/teles0.c           |    2 -
 drivers/isdn/hisax/teles3.c           |    1 
 12 files changed, 63 insertions(+), 44 deletions(-)
