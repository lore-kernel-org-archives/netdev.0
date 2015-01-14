From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 0/2] cxgb4/cxgb4i : Update & use ipv6 handling api
Date: Tue, 13 Jan 2015 18:28:34 -0800
Message-ID: <1421202516-13862-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, kxie@chelsio.com,
	deepak.s@chelsio.com, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:20670 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752116AbbANC2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 21:28:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series consolidates and updates the ipv6 api, as well as exports
it for use by upper level drivers dependent on cxgb4

Anish Bhatt (2):
  cxgb4: Update ipv6 address handling api
  cxgb4i : Call into recently added cxgb4 ipv6 api

 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c      | 314 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h      |  41 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  19 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 228 +++++----------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   3 -
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 |  23 +-
 8 files changed, 469 insertions(+), 164 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h

-- 
2.2.1
