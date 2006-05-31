From: Amit K Arora <aarora@in.ibm.com>
Subject: DPRINTKs in e1000 code (2.6.x kernels)
Date: Wed, 31 May 2006 14:31:05 +0530
Message-ID: <447D5B51.7030100@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:42476 "EHLO
	e34.co.us.ibm.com") by vger.kernel.org with ESMTP id S965167AbWEaVc1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 17:32:27 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4VLWLhH019590
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 31 May 2006 17:32:22 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k4VLWKuj039858
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 31 May 2006 15:32:20 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k4VLWJxx032439
	for <netdev@vger.kernel.org>; Wed, 31 May 2006 15:32:19 -0600
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am wondering why this patch "e1000: Remove PM warning DPRINTKs 
breaking 2.4.x kernels" 
(http://www.mail-archive.com/netdev@vger.kernel.org/msg10803.html) was 
meant only for 2.4 kernels, and _not_ for 2.6 kernels.

These DPRINTKs in e1000_suspend() are currently resulting in following 
messages while rebooting a system (2.6 kernel) which has e1000 adapter:

	Shutting down MD Raid 
    	done
	Stopping udevd:                                                       	done
	proc umounted
	The system will be halted immediately.
	md: stopping all md devices.
	e1000: eth3: e1000_suspend: Error enabling D3 wake	<<==
	e1000: eth3: e1000_suspend: Error enabling D3 cold wake	<<==
	Power down.


Should these DPRINTKs be removed from the 2.6.x e1000 code as well ?

Regards,
Amit Arora

