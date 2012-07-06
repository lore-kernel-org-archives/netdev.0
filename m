From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: [PATCH net-next v2 0/4] 6lowpan: Various bug fixes
Date: Fri,  6 Jul 2012 00:50:21 -0400
Message-ID: <1341550225-13112-1-git-send-email-tony.cheneau@amnesiak.org>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:41210 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004Ab2GFEvc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 00:51:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

After reading and playing with the 6lowpan code, I found out a few issues. This
patchset fixes them. This patchset should apply cleanly against the current
net-next. It contains only bug fixes, I'll send later on an other patchset that
will contain new functionalities.

Alexander commented on the previous version of this patchset and made me
understand that the commit messages were not specific enough. This new version
hopefully improves that.

This is a set of 4 small patches that correct bugs in 6lowpan:
- patch 1 fixes a potential crash when reassembling UDP fragments
- patch 2 fixes a type length issues that prevent the fragmentation reassembly
  to operate properly.
- patch 3 and 4 corrects field encoding issues (byte order was not right)

Hope it helps.

Regards,
	Tony Cheneau

 net/ieee802154/6lowpan.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

-- 
1.7.3.4
