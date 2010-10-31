From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
Subject: [ANNOUNCE] Host Fabric Interface (HFI) device driver available on
 sourceforge
Date: Sat, 30 Oct 2010 23:10:27 -0400
Message-ID: <4CCCDE23.1090202@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:51414 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753642Ab0JaDKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 23:10:36 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9V358K4003964
	for <netdev@vger.kernel.org>; Sat, 30 Oct 2010 21:05:08 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9V3AXON179256
	for <netdev@vger.kernel.org>; Sat, 30 Oct 2010 21:10:33 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9V3AWA0003583
	for <netdev@vger.kernel.org>; Sat, 30 Oct 2010 21:10:32 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The HFI network interface is the internal cluster fabric of IBM's PERCS 
supercomputer. The device driver patch for 2.6.36, hfi-utils, and an 
introduction to the hardware are available on the sourceforge page 
(http://sourceforge.net/projects/hfidevicedriver). The hardware design 
is under US export control, so we cannot release hardware specs.

The HFI device driver allows direct user-space access to network 
resources; a reference library will be uploaded to 
http://sourceforge.net/projects/halreferencelib in the next few days.

The driver has been running in the lab for several months. The 
user-space access is essentially complete. We are still working on IPv6, 
and we are now starting work on an ofed-over-hfi driver, but we'd like 
to start the review process without them.

Jim Dykman

