From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/4] bonding: fixes for 2.6.25
Date: Fri, 21 Mar 2008 22:29:32 -0700
Message-ID: <12061637763004-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:34468 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366AbYCVF3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 01:29:43 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2M5TbO2017148
	for <netdev@vger.kernel.org>; Sat, 22 Mar 2008 01:29:37 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2M5Tbm9212294
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 23:29:37 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2M5TbiW030435
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 23:29:37 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Included are patches for 2.6.25, two bug fixes, a patch for a
couple of compiler warnings, and an update to the version, as
follows:

	1. Fix deadlock in 802.3ad due to lack of _bh on lock.  Can
deadlock if LACPDU arrives at just the wrong time.

	2. Fix two compilers warnings that show up with gcc >= 4.2.

	3. Fix error in sysfs cleanup during module removal

	4. Bump driver version to 3.2.5.

	Please apply for 2.6.25.

	Thanks,

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
