From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 0/2] qlcnic: Bug fixes
Date: Wed, 23 Apr 2014 09:59:54 -0400
Message-ID: <1398261596-7296-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:42962 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751620AbaDWOhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 10:37:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi David,

This patch series contains following fixes -

* Fix memory leak caused because of issuing mailbox
  command which can not wait for its completion.
* Reset firmware API lock which might be in inconsistent state.

Please apply this series to net.

Thanks,
Shahed

Rajesh Borundia (1):
  qlcnic: Fix memory leak.

Sony Chacko (1):
  qlcnic: Reset firmware API lock at driver load time

 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    9 +++++++++
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    9 ++++++++-
 2 files changed, 17 insertions(+), 1 deletions(-)
