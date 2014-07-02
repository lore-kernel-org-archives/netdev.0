From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 net 0/2] xen-netfront: multi-queue related locking fixes
Date: Wed, 2 Jul 2014 16:09:13 +0100
Message-ID: <1404313755-27349-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:46520 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbaGBPJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 11:09:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two fixes to the per-queue locking bugs in xen-netfront that were
introduced in 3.16-rc1 with the multi-queue support.

David
