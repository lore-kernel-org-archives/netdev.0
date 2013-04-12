From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH V4 0/7] Bundle fixes for Xen netfront / netback
Date: Fri, 12 Apr 2013 15:23:59 +0100
Message-ID: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <annie.li@oracle.com>, <konrad.wilk@oracle.com>,
	<jbeulich@suse.com>, <ian.campbell@citrix.com>,
	<wdauchy@gmail.com>, <david.vrabel@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:6348 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680Ab3DLOYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 10:24:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1-3 have been applied to DaveM's tree, repost for completeness.

4 is an incremental patch on top of 2.

5 now accounts for MAX_TCP_HEADER instead of vlan ethernet header.

6 now only touches TX path, RX path still has MAX_SKB_FRAGS dependency.

7 is modified to adapt to 6.


Wei.
