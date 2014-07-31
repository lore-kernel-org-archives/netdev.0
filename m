From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH net 0/3] xen-netfront: more multiqueue fixes
Date: Thu, 31 Jul 2014 17:38:21 +0100
Message-ID: <1406824704-2275-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48493 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751858AbaGaQic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 12:38:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few more xen-netfront fixes for the multiqueue support added in
3.16-rc1.  It would be great if these could make it into 3.16 but I
suspect it's a little late for that now.

The second patch fixes a significant resource leak that prevents
guests from migrating more than a handful of times.

These have been tested by repeatedly migrating a guest over 250 times
(it would previously fail with this guest after only 8 iterations).

David
