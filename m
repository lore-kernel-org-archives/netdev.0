From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH 00/27] HFI minimal device driver/network driver
Date: Wed,  2 Mar 2011 16:19:55 -0500
Message-ID: <1299100795-9028-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:42652 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755096Ab1CBVUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 16:20:06 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p22L7LGp011372
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 14:07:21 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p22LK5LR122374
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 14:20:05 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p22LOlhX000578
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 14:24:47 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

The HFI ("Host Fabric Interface") network interface is the internal cluster 
fabric of IBM's PERCS supercomputer. The hardware design is under US export 
control, so we cannot release hardware specs. There is a writeup of 
publically available information about the system available here:
http://sourceforge.net/projects/hfidevicedriver/files/docs/hfi_general_desc_v2.1.txt

hfi_core contains the resource management to set up communications paths for
network traffic. Calls are provided for kernel drivers, and also for setting
up direct user-space access to HFI windows.
hf_if contains the kernel network driver.

The driver has been running in the lab for several months. The full patch is
around 22000 lines, so we've split out a minimal device/network driver that 
can send and receive through the simplest path.  Once that much gets reviewed 
we'll start adding on to it.

Patches are against net-2.6 (Is that the correct tree for us to use?).

Jim Dykman
