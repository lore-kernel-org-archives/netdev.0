From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 0/2 net] xen-netback: fix ethtool stats and memory
Date: Tue, 3 Mar 2015 16:26:09 +0000
Message-ID: <1425399971-27630-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:36668 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757163AbbCCQaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 11:30:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of bug fixes for netback:
- make ethool stats to report the correct values.
- don't leak 1 MiB every time a VIF is destroyed.

David
