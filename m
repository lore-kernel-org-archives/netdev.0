From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 0/4] qlcnic: bug fixes
Date: Tue, 28 Jan 2014 11:55:26 -0500
Message-ID: <1390928130-10710-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:55917 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755182AbaA1RaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 12:30:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch series contains following bug fixes

o Bound checks for number of receive descriptors and number of recieve rings.
  Both of these have off-by-one errors.
o Vlan list was getting re-initialized in case of adapter reset.
o Tx queue was timing out because of missing start queue for a corresponding
  netif_tx_disable.
o Loopback test failed because driver was not setting linkup variable
  while handling link events.
 
Please apply to net.

Manish Chopra (1):
  qlcnic: Correct off-by-one errors in bounds checks

Rajesh Borundia (2):
  qlcnic: Fix initialization of vlan list.
  qlcnic: Fix tx timeout.

Shahed Shaikh (1):
  qlcnic: Fix loopback test failure

 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   19 ++++++++++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    9 ++-------
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   11 +++++------
 3 files changed, 19 insertions(+), 20 deletions(-)
