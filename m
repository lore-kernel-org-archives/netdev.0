From: Arun Easi <arun.easi@cavium.com>
Subject: qed, qedi patchset submission
Date: Mon, 14 Nov 2016 13:53:50 -0800
Message-ID: <alpine.LRH.2.00.1611141256340.28058@mvluser05.qlc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
To: "Martin K. Petersen" <martin.petersen@oracle.com>,
        David Miller <davem@davemloft.net>,
        <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0076.outbound.protection.outlook.com ([104.47.40.76]:26451
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S941056AbcKNWJo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 17:09:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin, David,

This is regarding the submission of the recent patch series we have posted
to linux-scsi and netdev:

    [PATCH v2 0/6] Add QLogic FastLinQ iSCSI (qedi) driver.
    [PATCH v2 1/6] qed: Add support for hardware offloaded iSCSI.
    [PATCH v2 2/6] qed: Add iSCSI out of order packet handling.
    [PATCH v2 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver framework.
    [PATCH v2 4/6] qedi: Add LL2 iSCSI interface for offload iSCSI.
    [PATCH v2 5/6] qedi: Add support for iSCSI session management.
    [PATCH v2 6/6] qedi: Add support for data path.

Patches 1 & 2 are "qed" module patches that goes under
drivers/net/ethernet/qlogic/qed/ and include/linux/qed/ directory.
	- These are the iSCSI enablement changes to the common "qed"
	  module. There is no dependency for these patches and so
	  can go independently.

Patches 3, 4, 5 & 6 are the qedi patches that is aimed towards
drivers/scsi/qedi/ directory.
	- These are the core qedi changes and is dependent on the
	  qed changes (invokes qed_XXX functions).

As qed sits in the net tree, the patches are usually submitted via netdev.

Do you have any preference or thoughts on how the "qed" patches be 
approached? Just as a reference, our rdma driver "qedr" went through 
something similar[1], and eventually "qed" patches were taken by David 
in the net tree and "qedr", in the rdma tree (obviously) by Doug L.

Hi David,

For the "qed" enablement sent with the v2 series, we did not prefix the 
qed patches with "[PATCH net-next]" prefix, so netdev folks may have 
failed to notice/review that, sorry about that. We will send the next (v3) 
series with that corrected.

Right now, we are basing the "qed" patches on top of latest net + net-next 
tree. FYI, I tried a test merge of net-next/master + qed patches with 
"net/master" and I see no conflict in qed.

Regards,
-Arun

[1] http://marc.info/?l=linux-rdma&m=147509152719831&w=2
