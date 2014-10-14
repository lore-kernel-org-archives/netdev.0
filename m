From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net 0/4] ipv6 and related cleanup for cxgb4/cxgb4i
Date: Tue, 14 Oct 2014 15:13:07 -0700
Message-ID: <1413324791-12104-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	kxie@chelsio.com, manojmalviya@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43756
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932569AbaJNWNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 18:13:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set removes some duplicated/extraneous code from cxgb4i, and guards
cxgb4 against compilation failure based on ipv6 tristate.

Anish Bhatt (4):
  cxgb4i : Remove duplicated code from cxgb4i, fucntionality already
    present in cxgb4
  cxgb4 : Fix build failure in cxgb4 when ipv6 is disabled/not in-built
  cxgb4i : All this code is only needed when IPV6 is enabled, disable
    when not required, also fixes -Wunused-function warning
  cxgb4i: Remove duplicate call to dst_neigh_lookup()

 drivers/net/ethernet/chelsio/Kconfig            |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  15 +++
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c              | 146 ++----------------------
 drivers/scsi/cxgbi/libcxgbi.c                   |   2 +
 4 files changed, 26 insertions(+), 139 deletions(-)

-- 
2.1.2
