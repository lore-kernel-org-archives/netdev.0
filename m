From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] ss: Implement sctp_diag support
Date: Sat, 30 Jul 2016 00:27:18 +0200
Message-ID: <1469831240-30322-1-git-send-email-phil@nwl.cc>
Cc: Xin Long <lucien.xin@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57968 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753882AbcG2W1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 18:27:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds the necessary bits to make use of recently added
sctp_diag module in Linux. There are a few pending kernel fixes
currently under review which this series kind of depends on, but it is
already useable as is (although a bit buggy here and there).

The first patch adds include/linux/sctp.h which albeit existing in
kernel uapi headers contains modifications included in above mentioned
kernel fixes so doesn't comply with upstream and therefore shouldn't be
applied as-is (at least not now). Probably it will be obsoleted by the
usual kernel headers import anyway.

So please don't consider this series as the final word, but rather a
base for early review/testing and feedback.

Phil Sutter (2):
  include: Add linux/sctp.h
  ss: Add support for SCTP protocol

 include/linux/sctp.h | 1005 ++++++++++++++++++++++++++++++++++++++++++++++++++
 misc/ss.c            |  212 ++++++++++-
 2 files changed, 1209 insertions(+), 8 deletions(-)
 create mode 100644 include/linux/sctp.h

-- 
2.8.2
