From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/4][SCTP]: Don't export include/linux/sctp.h to userspace.
Date: Wed, 20 Dec 2006 16:00:39 -0800
Message-ID: <1166659239.5722.15.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:35370 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964855AbWLUAAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 19:00:43 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBL00ftp002156
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 19:00:41 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBL00fIw213276
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 19:00:41 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBL00fa0025173
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 19:00:41 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Don't export include/linux/sctp.h to userspace.

This file contains protocol definitions and there are no SCTP apps that use
this file.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/linux/Kbuild |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index a1b04d8..f2d75f3 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -138,7 +138,6 @@ header-y += radeonfb.h
 header-y += raw.h
 header-y += resource.h
 header-y += rose.h
-header-y += sctp.h
 header-y += smbno.h
 header-y += snmp.h
 header-y += sockios.h


