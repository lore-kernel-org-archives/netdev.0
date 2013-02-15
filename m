From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 0/8] Bugfix and mechanical works for Xen network driver
Date: Fri, 15 Feb 2013 16:00:01 +0000
Message-ID: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:27169 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755976Ab3BOQAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 11:00:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series contains a small fix plus mechanical works for xen network
driver.

 * bug fix: don't bind kthread to specific cpu core
 * allow host admin to unload netback
 * multi-page ring support
 * split event channels support
