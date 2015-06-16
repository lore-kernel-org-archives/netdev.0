From: Praveen Madhavan <praveenm@chelsio.com>
Subject: RE: [PATCH 0/3] csiostor:Debugfs support update.
Date: Tue, 16 Jun 2015 01:20:25 +0000
Message-ID: <24C222ADD7729F4FB5113B41FF0028A1C6ECF9@nice.asicdesigners.com>
References: <1433855686-15768-1-git-send-email-praveenm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"JBottomley@parallels.com" <JBottomley@parallels.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	"Varun Prakash" <varun@chelsio.com>,
	Rajesh Kumar <rajesh.kumar@chelsio.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6976 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbbFPBUf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 21:20:35 -0400
In-Reply-To: <1433855686-15768-1-git-send-email-praveenm@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Davem,
Can you please apply this patch series against net-next ?

Thanks
Praveen
________________________________________
From: Praveen Madhavan [praveenm@chelsio.com]
Sent: Tuesday, June 09, 2015 6:44 PM
To: netdev@vger.kernel.org; linux-scsi@vger.kernel.org
Cc: davem@davemloft.net; JBottomley@parallels.com; Hariprasad S; Praveen Madhavan; Varun Prakash; Rajesh Kumar
Subject: [PATCH 0/3] csiostor:Debugfs support update.

This patch series adds debugfs functionality to dump adapter log,
adapter queues and fcoe DDP stats.

This patch has been created against net-next.

Praveen Madhavan (3):
  csiostor:Add devlog mailbox support.
  csiostor:Cleanup debugfs.
  csiostor:Adds debugfs support.

 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |    1 +
 drivers/scsi/csiostor/Makefile               |    2 +-
 drivers/scsi/csiostor/csio_debugfs.c         | 1100 ++++++++++++++++++++++++++
 drivers/scsi/csiostor/csio_hw.c              |   72 +-
 drivers/scsi/csiostor/csio_hw.h              |   12 +
 drivers/scsi/csiostor/csio_init.c            |  132 ----
 drivers/scsi/csiostor/csio_init.h            |    4 +
 drivers/scsi/csiostor/csio_mb.c              |   60 +-
 drivers/scsi/csiostor/csio_mb.h              |   17 +-
 9 files changed, 1237 insertions(+), 163 deletions(-)
 create mode 100644 drivers/scsi/csiostor/csio_debugfs.c

--
2.0.2
