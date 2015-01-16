From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Stable request for "hw csum failure" fixes
Date: Fri, 16 Jan 2015 10:30:57 -0800
Message-ID: <7016.1421433057@famine>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55853 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbbAPSbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:31:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Please consider commits

commit 17e96834fd35997ca7cdfbf15413bcd5a36ad448
Author: Govindarajulu Varadarajan <_govind@gmx.com>
Date:   Thu Dec 18 15:58:42 2014 +0530

    enic: fix rx skb checksum

commit 2c26d34bbcc0b3f30385d5587aa232289e2eed8e
Author: Jay Vosburgh <jay.vosburgh@canonical.com>
Date:   Fri Dec 19 15:32:00 2014 -0800

    net/core: Handle csum for CHECKSUM_COMPLETE VXLAN forwarding
    

	for -stable kernels back to 3.10.

	These patches have been confirmed to fix the "hw csum failure"
issue in the Ubuntu 3.13 kernel, and code inspection suggests that the
3.12 and 3.10 kernels would also exhibit the problem.

	Thanks,

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
