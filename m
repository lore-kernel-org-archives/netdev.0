From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v3 0/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Fri, 31 Aug 2007 15:35:49 -0700
Message-ID: <1188599749.5176.10.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com
To: davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1691 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965381AbXHaVjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 17:39:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Third version of the iSCSI patch for BNX2 which has addressed the
comments we have received.  I know there is general dislike about this
stuff on netdev, as shown by the RDMA discussions.  iSCSI is at least a
bit more mainstream.  David, please consider merging this for 2.6.24.
Thanks.

Full patch available from ftp:

ftp://Net_sys_anon@ftp1.broadcom.com/0003-BNX2-Add-iSCSI-support-to-BNX2-devices.patch

Firmware blob omitted in the next 2 emails for review.

--

[BNX2]: Add iSCSI support to BNX2 devices.

Modify bnx2 and add a cnic driver to support some offload functions
needed by iSCSI.

Add a new open-iscsi driver to support iSCSI offload on bnx2 devices.

Signed-off-by: Anil Veerabhadrappa <anilgv@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/Kconfig                       |   10 +
 drivers/net/Makefile                      |    1 +
 drivers/net/bnx2.c                        |  117 +-
 drivers/net/bnx2.h                        |   21 +-
 drivers/net/bnx2_fw.h                     | 7039 ++++++++++++++++++-----------
 drivers/net/cnic.c                        | 1881 ++++++++
 drivers/net/cnic.h                        |  163 +
 drivers/net/cnic_cm.h                     |  555 +++
 drivers/net/cnic_if.h                     |  152 +
 drivers/scsi/Kconfig                      |    2 +
 drivers/scsi/Makefile                     |    1 +
 drivers/scsi/bnx2i/57xx_iscsi_constants.h |  212 +
 drivers/scsi/bnx2i/57xx_iscsi_hsi.h       | 1501 ++++++
 drivers/scsi/bnx2i/Kconfig                |    7 +
 drivers/scsi/bnx2i/Makefile               |    4 +
 drivers/scsi/bnx2i/bnx2i.h                |  841 ++++
 drivers/scsi/bnx2i/bnx2i_hwi.c            | 1977 ++++++++
 drivers/scsi/bnx2i/bnx2i_init.c           |  400 ++
 drivers/scsi/bnx2i/bnx2i_iscsi.c          | 3578 +++++++++++++++
 drivers/scsi/bnx2i/bnx2i_sysfs.c          |  615 +++
 20 files changed, 16440 insertions(+), 2637 deletions(-)
 create mode 100644 drivers/net/cnic.c
 create mode 100644 drivers/net/cnic.h
 create mode 100644 drivers/net/cnic_cm.h
 create mode 100644 drivers/net/cnic_if.h
 create mode 100644 drivers/scsi/bnx2i/57xx_iscsi_constants.h
 create mode 100644 drivers/scsi/bnx2i/57xx_iscsi_hsi.h
 create mode 100644 drivers/scsi/bnx2i/Kconfig
 create mode 100644 drivers/scsi/bnx2i/Makefile
 create mode 100644 drivers/scsi/bnx2i/bnx2i.h
 create mode 100644 drivers/scsi/bnx2i/bnx2i_hwi.c
 create mode 100644 drivers/scsi/bnx2i/bnx2i_init.c
 create mode 100644 drivers/scsi/bnx2i/bnx2i_iscsi.c
 create mode 100644 drivers/scsi/bnx2i/bnx2i_sysfs.c



