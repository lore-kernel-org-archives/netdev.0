From: "Michael Chan" <mchan@broadcom.com>
Subject: [RFC 0/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Fri, 03 Aug 2007 21:03:49 -0700
Message-ID: <1186200229.18322.97.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com
To: davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1514 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266AbXHDDJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 23:09:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add iSCSI support to BNX2 devices.

Modify bnx2 and add a cnic driver to support some offload functions
needed by iSCSI.

Add a new open-iscsi driver to support iSCSI offload on bnx2 devices.

Signed-off-by: Anil Veerabhadrappa <anilgv@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

--

The complete patch is in:

ftp://Net_sys_anon@ftp1.broadcom.com/0001-BNX2-Add-iSCSI-support-to-BNX2-devices.patch

I broke this into 2 patches and omitted the firmware blob in the next 2
emails for review.

---
 drivers/net/Kconfig                       |   10 +
 drivers/net/Makefile                      |    1 +
 drivers/net/bnx2.c                        |  116 +-
 drivers/net/bnx2.h                        |   25 +-
 drivers/net/bnx2_fw.h                     | 7036 ++++++++++++++++++-----------
 drivers/net/cnic.c                        | 1885 ++++++++
 drivers/net/cnic.diff                     |  363 ++
 drivers/net/cnic.h                        |  163 +
 drivers/net/cnic_cm.h                     |  555 +++
 drivers/net/cnic_if.h                     |  152 +
 drivers/scsi/Kconfig                      |    2 +
 drivers/scsi/Makefile                     |    1 +
 drivers/scsi/bnx2i/57xx_iscsi_constants.h |  212 +
 drivers/scsi/bnx2i/57xx_iscsi_hsi.h       | 1501 ++++++
 drivers/scsi/bnx2i/Kconfig                |    7 +
 drivers/scsi/bnx2i/Makefile               |    4 +
 drivers/scsi/bnx2i/bnx2i.h                |  828 ++++
 drivers/scsi/bnx2i/bnx2i_hwi.c            | 1993 ++++++++
 drivers/scsi/bnx2i/bnx2i_init.c           |  393 ++
 drivers/scsi/bnx2i/bnx2i_iscsi.c          | 3718 +++++++++++++++
 drivers/scsi/bnx2i/bnx2i_sysfs.c          |  616 +++


