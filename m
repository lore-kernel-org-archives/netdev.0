From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/4] bonding: fix module multiple load issues
Date: Fri, 19 Jan 2007 18:15:15 -0800
Message-ID: <200701200215.l0K2FF22021615@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Patrick McHardy <kaber@trash.net>,
	mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:36001 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932879AbXATCQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 21:16:28 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0K2GRj8012000
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:16:27 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0K2FIIV257852
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:15:18 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0K2FHDO030465
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:15:17 -0500
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Patch 1: fix device name allocation error
	Patch 2: fix error check in sysfs creation
	Patch 3: modify sysfs support to permit multiple loads
	Patch 4: update version number

	This patch series should resolve whatever problems there are
with the logic to load the module multiple times.  This code changed
during the introduction of sysfs, and some recent tightening of the
sysfs creation code (checking for duplicates) broke that.

	The multiple load logic is used primarily by the initscripts and
sysconfig packages, to automatically configure multiple bonding
interfaces at boot time.

	Originally reported by Patrick McHardy <kaber@trash.net>.

	Patches generated against netdev-2.6 (hope that's ok).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
