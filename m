From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [RFC 0/2]: Add minimum bandwidth support in IP tool.
Date: Wed, 5 Mar 2014 02:33:34 -0500
Message-ID: <1394004816-23436-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:23431 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751249AbaCEIJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 03:09:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today IP tool allows configuring only maximum bandwidth.
Likewise minimum bandwidth can also be configured for a VF. It puts
lower limit on the VF bandwidth. VF is guaranteed to have a bandwidth
of at least this value.

With this change, user can alter minimum bandwidth rate.

This change will also require change in IP tool. I am also sending that
patch separately.

The below patch series has 2 patches:
1st patch is a kernel patch that adds required support in kernel.
2nd patch adds support in qlcnic driver.

Please comment.

Thanks,
Sucheta.

Sucheta Chakraborty (2):
  net: Add support to configure SR-IOV VF minimum and maximum Tx rate through ip tool.
  qlcnic: Add support to configure SR-IOV VF minimum and maximum Tx rate through ip tool.


 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |   1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   | 102 +++++++++++++++++++--
 include/linux/if_link.h      |  2 ++
 include/linux/netdevice.h    |  5 +++++
 include/uapi/linux/if_link.h |  9 ++++++++-
 net/core/rtnetlink.c         | 29 +++++++++++++++++++++++++++++
 7 files changed, 138 insertions(+), 11 deletions(-)
