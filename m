From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] net/s390 drivers: add missing 'const' attribute
Date: Tue, 17 Nov 2009 14:48:15 +0100
Message-ID: <20091117134815.GE5124@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ursula Braun <braunu@de.ibm.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:46698 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbZKQNtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 08:49:06 -0500
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate7.uk.ibm.com (8.14.3/8.13.8) with ESMTP id nAHDmPTn334942
	for <netdev@vger.kernel.org>; Tue, 17 Nov 2009 13:48:30 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAHDmFkJ962570
	for <netdev@vger.kernel.org>; Tue, 17 Nov 2009 13:48:15 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id nAHDmFRc002132
	for <netdev@vger.kernel.org>; Tue, 17 Nov 2009 13:48:15 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH] net/s390 drivers: add missing 'const' attribute

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Add missing 'const' attribute to avoid the following compile warnings:

drivers/s390/net/ctcm_main.c: In function 'ctcm_init':
drivers/s390/net/ctcm_main.c:1864: warning: assignment from incompatible pointer type
drivers/s390/net/lcs.c: In function 'lcs_init_module':
drivers/s390/net/lcs.c:2468: warning: assignment from incompatible pointer type
drivers/s390/net/claw.c: In function 'claw_init':
drivers/s390/net/claw.c:3408: warning: assignment from incompatible pointer type

Cc: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---

Patch applies on top of linux-next of 17th November.

 drivers/s390/net/claw.c      |    2 +-
 drivers/s390/net/ctcm_main.c |    2 +-
 drivers/s390/net/lcs.c       |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

Index: linux-next/drivers/s390/net/ctcm_main.c
===================================================================
--- linux-next.orig/drivers/s390/net/ctcm_main.c
+++ linux-next/drivers/s390/net/ctcm_main.c
@@ -1806,7 +1806,7 @@ static struct attribute_group ctcm_group
 	.attrs = ctcm_group_attrs,
 };
 
-static struct attribute_group *ctcm_group_attr_groups[] = {
+static const struct attribute_group *ctcm_group_attr_groups[] = {
 	&ctcm_group_attr_group,
 	NULL,
 };
Index: linux-next/drivers/s390/net/lcs.c
===================================================================
--- linux-next.orig/drivers/s390/net/lcs.c
+++ linux-next/drivers/s390/net/lcs.c
@@ -2440,7 +2440,7 @@ static struct attribute_group lcs_group_
 	.attrs = lcs_group_attrs,
 };
 
-static struct attribute_group *lcs_group_attr_groups[] = {
+static const struct attribute_group *lcs_group_attr_groups[] = {
 	&lcs_group_attr_group,
 	NULL,
 };
Index: linux-next/drivers/s390/net/claw.c
===================================================================
--- linux-next.orig/drivers/s390/net/claw.c
+++ linux-next/drivers/s390/net/claw.c
@@ -310,7 +310,7 @@ static struct attribute_group claw_group
 	.attrs = claw_group_attrs,
 };
 
-static struct attribute_group *claw_group_attr_groups[] = {
+static const struct attribute_group *claw_group_attr_groups[] = {
 	&claw_group_attr_group,
 	NULL,
 };
