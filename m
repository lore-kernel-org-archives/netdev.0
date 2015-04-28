From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 0/3] bnx2x: minor cleanups related to TPA bits
Date: Tue, 28 Apr 2015 11:34:20 +0200
Message-ID: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932510AbbD1Je0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 05:34:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed some simplification possibilities while looking into the bug
fixed by "bnx2x: really disable TPA if 'disable_tpa' is set'.

Michal Schmidt (3):
  bnx2x: mark LRO as a fixed disabled feature if disable_tpa is set
  bnx2x: merge fp->disable_tpa with fp->mode
  bnx2x: remove {TPA,GRO}_ENABLE_FLAG

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 67 +++++++++---------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 11 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c |  2 +-
 5 files changed, 33 insertions(+), 53 deletions(-)

-- 
2.1.0
