From: Anish Bhatt <anish@chelsio.com>
Subject: Updating net-next, infiniband & scsi tree simultaneously
Date: Mon, 14 Jul 2014 12:55:31 -0700
Message-ID: <1405367731-8908-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, michaelc@cs.wisc.edu,
	JBottomley@Parallels.com, kxie@chelsio.com, leedom@chelsio.com,
	hariprasad@chelsio.com, swise@opengridcomputing.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:33051
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754870AbaGNT63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 15:58:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave/Roland/Mike/James,
      I have an update to the cxgb4i(iscsi) driver that needs a change in the cxgb4 driver as well. To prevent code duplication, I'll be moving a few defines from the inifiniband(iw_cxgb4) driver to the cxgb4 which both cxgb4i & iw_cxgb4 rely on. What is the correct way to submit this changeset ? Submitting separate changesets to separate trees might break compilation in respective trees.
Thanks,
Anish

-- 
2.0.0
