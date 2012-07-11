From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: [PATCH net-next v3 0/3] 6lowpan: Various bug fixes
Date: Wed, 11 Jul 2012 12:51:13 -0400
Message-ID: <1342025476-20949-1-git-send-email-tony.cheneau@amnesiak.org>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:43744 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932958Ab2GKQw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 12:52:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

After reading and playing with the 6lowpan code, I found out a few issues. This
patchset fixes them. This patchset should apply cleanly against the current
net-next. It contains only bug fixes, I'll send later on an other patchset that
will contain new functionalities.

Changes since version 2:
- remove a patch that prevented fragmentation to work after few packets have
  been send: Alexander included the patch in his patchset
- fix the title of the git commit to include the "6lowpan" tag

Regards,
	Tony Cheneau

Tony Cheneau (3):
  Fix null pointer dereference in UDP uncompression function
  Change byte order when storing/accessing u16 tag
  Change byte order when storing/accessing to len field

 net/ieee802154/6lowpan.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

-- 
1.7.3.4
