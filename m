From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net 0/4] ibmvnic driver bugfixes and improvements
Date: Wed,  6 Jul 2016 15:35:14 -0500
Message-ID: <1467837318-31710-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, nfont@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55326 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755452AbcGFUfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 16:35:25 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u66KY2m9059040
	for <netdev@vger.kernel.org>; Wed, 6 Jul 2016 16:35:24 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2415xmf9fa-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 16:35:24 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Wed, 6 Jul 2016 14:35:23 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C12993E4003E
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 14:35:19 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miscellaneous fixes and improvements on the ibmvnic driver.

Thomas Falcon (4):
  ibmvnic: properly start and stop tx queues
  ibmvnic: dispose irq mappings
  ibmvnic: simplify and improve driver probe function
  ibmvnic: Fix passive VNIC server login process

 drivers/net/ethernet/ibm/ibmvnic.c | 227 +++++++++++++++++++++++++++----------
 drivers/net/ethernet/ibm/ibmvnic.h |   2 +
 2 files changed, 169 insertions(+), 60 deletions(-)

-- 
1.8.3.1
