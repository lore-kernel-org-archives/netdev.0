From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH for-next 0/2] Refactor macros to conform to uniform standards
Date: Fri, 16 Jan 2015 09:24:46 +0530
Message-ID: <1421380488-1111-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, praveenm@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5658 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932612AbbAPDtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 22:49:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series cleansup macros/register defines, defined in t4.h and
t4fw_ri_api.h and all the affected files.

This patch series is created against net-next tree and includes patches on
iw_cxgb4 tree. Since the patches are dependent on previous cleanup patched we
would line to get this series merged through net-next tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  iw_cxgb4: Cleanup register defines/MACROS defined in t4.h
  iw_cxgb4: Cleanup register defines/MACROS defined in t4fw_ri_api.h

 drivers/infiniband/hw/cxgb4/cm.c          |   30 +-
 drivers/infiniband/hw/cxgb4/cq.c          |   60 ++--
 drivers/infiniband/hw/cxgb4/device.c      |   12 +-
 drivers/infiniband/hw/cxgb4/ev.c          |   12 +-
 drivers/infiniband/hw/cxgb4/mem.c         |   18 +-
 drivers/infiniband/hw/cxgb4/qp.c          |   62 ++--
 drivers/infiniband/hw/cxgb4/t4.h          |   90 ++--
 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h |  812 ++++++++++++++--------------
 8 files changed, 548 insertions(+), 548 deletions(-)
