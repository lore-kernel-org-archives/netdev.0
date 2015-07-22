From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/6] bnx2x: update FW, rebrand and more
Date: Wed, 22 Jul 2015 09:16:21 +0300
Message-ID: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:13314 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753838AbbGVGQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 02:16:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series does several things - it updates the bnx2x FW into
7.12.30 which both contains some small fixes as well as opening the door
for several new features for the device - mainly vxlan/geneve offloads
and vlan filtering offload.
It then adds a new Multi-function mode [BD] which requires this FW in
order to operate.

In addition, this finally rebrands the driver from a 'broadcom' driver
into a 'qlogic' driver [although it would still reside under Broadcom's
tree in the kernel].

Dave,

Please consider applying this series to `net-next'.

[Do notice some of these don't pass checkpatch cleanly, usually due
to confirming with already existing 'bad' styles.
E.g., preprocessor `#define' which is shifted]

Thanks,
Yuval
-- 
1.8.3.1
