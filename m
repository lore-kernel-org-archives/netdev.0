From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/2] bonding: Two small fixes
Date: Tue,  6 Nov 2007 13:33:27 -0800
Message-ID: <11943848091427-git-send-email-fubar@us.ibm.com>
Cc: jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:52733 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729AbXKFVdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 16:33:36 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA6LXa33031837
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 16:33:36 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA6LXXd9127612
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 14:33:35 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA6LXXRu004219
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 14:33:33 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Two small fixes to bonding for the mainline.

	1: Mishandling of RTNL due to what looks like a merge error.

	2: Turn off the new validate_addr check when devices are set 
up.  For backwards compatibility, the bonding master must be able to be
set up with a MAC address of all zeroes.

	Patches are against linux-2.6, and apply cleanly
to netdev-2.6#upstream-linus.  Please apply for 2.6.24.

	-J


---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


