From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/8] wan: Use current logging forms
Date: Sun, 26 Jun 2011 22:01:27 -0700
Message-ID: <cover.1309150683.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3215 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756228Ab1F0FBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 01:01:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches (8):
  generic_hdlc: Update to current logging forms
  cosa: Update to current logging forms
  cyclom: Update to current logging forms
  frame relay dlci/frad: Update to current logging forms
  dscc4: Update to current logging forms
  farsync: Update to current logging forms
  ixp4xx_hss: Update to current logging forms
  wan: Update to current logging forms

 drivers/net/wan/c101.c         |   30 +++---
 drivers/net/wan/cosa.c         |  226 +++++++++++++++++++---------------------
 drivers/net/wan/cycx_drv.c     |   81 +++++++--------
 drivers/net/wan/cycx_main.c    |   31 +++---
 drivers/net/wan/cycx_x25.c     |  177 +++++++++++++++-----------------
 drivers/net/wan/dlci.c         |   22 +++--
 drivers/net/wan/dscc4.c        |   80 +++++++--------
 drivers/net/wan/farsync.c      |    7 +-
 drivers/net/wan/hd64570.c      |    8 +-
 drivers/net/wan/hd64572.c      |    8 +-
 drivers/net/wan/hdlc.c         |   16 ++--
 drivers/net/wan/hdlc_cisco.c   |   21 ++---
 drivers/net/wan/hdlc_fr.c      |   96 ++++++++----------
 drivers/net/wan/hdlc_ppp.c     |    9 +-
 drivers/net/wan/hdlc_x25.c     |   12 +--
 drivers/net/wan/hostess_sv11.c |   11 +-
 drivers/net/wan/ixp4xx_hss.c   |   28 +++---
 drivers/net/wan/lapbether.c    |   18 ++--
 drivers/net/wan/n2.c           |   42 ++++----
 drivers/net/wan/pc300_drv.c    |    4 +-
 drivers/net/wan/pc300too.c     |   36 +++----
 drivers/net/wan/pci200syn.c    |   29 +++---
 drivers/net/wan/sbni.c         |   67 ++++++------
 drivers/net/wan/sdla.c         |   52 ++++++----
 drivers/net/wan/sealevel.c     |   11 +-
 drivers/net/wan/wanxl.c        |   90 ++++++++---------
 drivers/net/wan/x25_asy.c      |   47 ++++----
 drivers/net/wan/z85230.c       |   34 +++---
 28 files changed, 620 insertions(+), 673 deletions(-)

-- 
1.7.6.rc1

