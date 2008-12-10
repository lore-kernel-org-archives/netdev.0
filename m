From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: [PATCH][RFC 21/23]: iSCSI target driver
Date: Wed, 10 Dec 2008 22:01:25 +0300
Message-ID: <49401205.8010207@vlnb.net>
References: <494009D7.4020602@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org
To: linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:53751 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756864AbYLJTBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 14:01:36 -0500
In-Reply-To: <494009D7.4020602@vlnb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains iSCSI-SCST target driver. This driver is a heavily 
modified forked with all respects IET 
(http://iscsitarget.sourceforge.net). Modifications were aimed to make a 
clearer, more reviewable and maintainable code as well as to fix many 
problems and make many improvements. See 
http://scst.sourceforge.net/target_iscsi.html for more details.

It has split user/kernel space architecture, where all management, 
sessions creation, parameters negotiation, etc. made in user space and 
data are transferred in the kernel space. Such architecture for iSCSI 
processing was many times acknowledged as the right one. Particularly, 
in-kernel iSCSI initiator (open-iscsi) has such architecture.

Signed-off-by: Vladislav Bolkhovitin <vst@vlnb.net>
---
  drivers/scst/iscsi-scst/Kconfig     |   25
  drivers/scst/iscsi-scst/Makefile    |    6
  drivers/scst/iscsi-scst/config.c    |  597 +++++++
  drivers/scst/iscsi-scst/conn.c      |  488 +++++
  drivers/scst/iscsi-scst/digest.c    |  221 ++
  drivers/scst/iscsi-scst/digest.h    |   31
  drivers/scst/iscsi-scst/event.c     |  116 +
  drivers/scst/iscsi-scst/iscsi.c     | 3066 ++++++++++++++++++++++++++++++++++++
  drivers/scst/iscsi-scst/iscsi.h     |  577 ++++++
  drivers/scst/iscsi-scst/iscsi_dbg.h |   73
  drivers/scst/iscsi-scst/iscsi_hdr.h |  517 ++++++
  drivers/scst/iscsi-scst/nthread.c   | 1522 +++++++++++++++++
  drivers/scst/iscsi-scst/param.c     |  263 +++
  drivers/scst/iscsi-scst/session.c   |  210 ++
  drivers/scst/iscsi-scst/target.c    |  306 +++
  include/scst/iscsi_scst.h           |  156 +
  include/scst/iscsi_scst_ver.h       |   16
  17 files changed, 8190 insertions(+)

The patch is too big to be submitted inline. You can find it in 
http://scst.sourceforge.net/patches/iscsi-scst.diff



