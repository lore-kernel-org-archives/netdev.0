From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 0/6 V2] Bundle fixes for Xen netfront / netback
Date: Mon, 25 Mar 2013 11:08:16 +0000
Message-ID: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <annie.li@oracle.com>,
	<konrad.wilk@oracle.com>, <david.vrabel@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:64946 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756518Ab3CYLJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 07:09:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1, 3 and 4 are just mechanical fixes to make code cleaner.

2 fixes the bug that netfront generates oversize skbs. The fix was suggested by
Ben. My test shows that netfront doesn't generate oversize skb after this fix.

4 tries to coalesce slots before copying. This version enlarges the grant copy
buffer to avoid overflow.

6 loosens the punishment when netback sees oversize packet.


Wei.
