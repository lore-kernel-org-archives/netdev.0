From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH v2 net-next 0/4] bnx2x, cnic, bnx2fc: add support for BD
Date: Tue, 4 Aug 2015 09:37:26 +0300
Message-ID: <1438670250-20130-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <James.bottomley@HansenPartnership.com>,
	<linux-scsi-owner@vger.kernel.org>, <chad.dupuis@qlogic.com>,
	<Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:4234 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751967AbbHDGhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 02:37:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 230d00eb4bfe ("bnx2x: new Multi-function mode - BD") added support
for a new multi-function mode, but it added only the support required by
bnx2x for L2 interfaces.

This adds the required changes to support the new multi-function mode in
the offloaded storage protocols.

Dave,

Please consider applying this series to `net-next'.

Do notice that this involves non-networking driver changes -
but sending this as a single series seemed like the best approach as
we had to have bnx2x changes to support the new functionality.
If this is problematic, please tell us what's the preferred solution here.

Changes from previous versions
------------------------------

 - From v1 - no actual changes; v1 failed to reach netdev so in order to
   keep things in line I've termed this one v2.

Thanks,
Yuval
-- 
1.8.3.1
