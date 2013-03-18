From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 0/4] Bundle fixes for xen-netfront/back
Date: Mon, 18 Mar 2013 10:35:51 +0000
Message-ID: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:8512 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750913Ab3CRKgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 06:36:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains 4 patches for Xen netfront and netback modules.

1 and 3 just remove some unused variables, nothing special.

2 is used to drop malformed packets in netfront before sending it to netback.

4 is used to deal with the situation when netfront's MAX_SKB_FRAGS is bigger
than netback's MAX_SKB_FRAGS.
