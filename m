From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/2][ATM]: Move linux/device.h include in linux/atmdev.h to #ifdef __KERNEL__ section
Date: Thu, 07 Sep 2006 17:58:44 -0400
Message-ID: <200609072158.k87Lwinq022169@relax.cmf.nrl.navy.mil>
Cc: davem@davemloft.net, ismail@pardus.org.tr
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:27363 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1751882AbWIGV7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 17:59:00 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: Move linux/device.h include in linux/atmdev.h to #ifdef __KERNEL__ section

linux/device.h header is not included in the David Woodhouse's
kernel-headers git tree which is used for userspace kernel headers. Which
results in compile errors when building iproute2.

Signed-off-by: Ismail Donmez <ismail@pardus.org.tr>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 0293994f3f7a3a4bc4db6e286473e9b422b8f582
tree b8b24f8e3025e23dbeb61dc101ca1f35f8efaf8e
parent 837a0955d484497fc6b0b1991d9cf77fb74f15e8
author chas williams <chas@relax.cmf.nrl.navy.mil> Thu, 07 Sep 2006 15:14:26 -0400
committer chas williams <chas@relax.cmf.nrl.navy.mil> Thu, 07 Sep 2006 15:14:26 -0400

 include/linux/atmdev.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 41788a3..2096e5c 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -7,7 +7,6 @@ #ifndef LINUX_ATMDEV_H
 #define LINUX_ATMDEV_H
 
 
-#include <linux/device.h>
 #include <linux/atmapi.h>
 #include <linux/atm.h>
 #include <linux/atmioc.h>
@@ -210,6 +209,7 @@ #define ATM_VF2TXT_MAP \
 
 #ifdef __KERNEL__
 
+#include <linux/device.h>
 #include <linux/wait.h> /* wait_queue_head_t */
 #include <linux/time.h> /* struct timeval */
 #include <linux/net.h>
