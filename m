From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net v2 0/4] ibmvnic driver bugfixes and improvements
Date: Fri,  8 Jul 2016 02:09:02 -0500
Message-ID: <1467961746-26023-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, nfont@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:59331 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751427AbcGHHJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 03:09:12 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u68796H4121419
	for <netdev@vger.kernel.org>; Fri, 8 Jul 2016 03:09:11 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2415xp9603-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 03:09:11 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Fri, 8 Jul 2016 01:09:10 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C884E1FF0045
	for <netdev@vger.kernel.org>; Fri,  8 Jul 2016 01:08:51 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miscellaneous fixes and improvements on the ibmvnic driver.

Thomas Falcon (4):
  ibmvnic: properly start and stop tx queues
  ibmvnic: dispose irq mappings
  ibmvnic: simplify and improve driver probe function
  ibmvnic: Fix passive VNIC server login process

 drivers/net/ethernet/ibm/ibmvnic.c | 231 +++++++++++++++++++++++++++----------
 drivers/net/ethernet/ibm/ibmvnic.h |   2 +
 2 files changed, 169 insertions(+), 64 deletions(-)
