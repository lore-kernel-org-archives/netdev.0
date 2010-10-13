From: Keith Mannthey <kmannth@us.ibm.com>
Subject: bnx2 is spamming dmesg
Date: Wed, 13 Oct 2010 14:30:34 -0700
Message-ID: <1287005434.8004.32.camel@keith-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:51653 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309Ab0JMVag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 17:30:36 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9DLA4pC010732
	for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 17:10:04 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9DLUZBl455968
	for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 17:30:35 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9DLUYrl028728
	for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 15:30:35 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All,
  For the last couple of months (since at least 2.6.35 somewhere) I have
been seeing 

"
....
[698612.423825] Device 0000:0b:00.0 unmapping: pfn ffc74-ffc74
[698612.423831] Device 0000:0b:00.0 unmapping: pfn ff96d-ff96d
[698612.639262] Device 0000:0b:00.0 unmapping: pfn ffc74-ffc74
[698612.639269] Device 0000:0b:00.0 unmapping: pfn ff96d-ff96d
....
"
in my dmesg output.  

"
 lspci -s 0000:0b:00.0
0b:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709
Gigabit Ethernet (rev 20)
"

The bnx2 driver is loaded on my system.  I am presently on 2.6.36-rc3
kernels but like I mentioned I have been seeing this for a while.


Any ideas? I would rather not have this endless message in my kernel
logs. 


Thanks,
  Keith Mannthey 
  IBM LTC Local Filesystems  




