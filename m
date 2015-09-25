From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/3] improve MACVLAN/MACVTAP support
Date: Fri, 25 Sep 2015 14:09:48 +0200
Message-ID: <1443182991-4628-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:45336 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754567AbbIYMJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 08:09:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While implementing support for MACVLAN_FLAG_NOPROMISC, I realized how similar
iplink_macvlan.c and iplink_macvtap.c are and that the main differences (apart
from substituting "macvlan" for "macvtap") were fixes and enhancements which
weren't applied to both files. To prevent this in the future and to share
common code, this series merges the files. In addition, it implements support
for MACVLAN_FLAG_NOPROMISC and finally documents these interface types in
ip-link.8.in.

Phil Sutter (3):
  ip: link: consolidate macvlan and macvtap
  ip: macvlan: support MACVLAN_FLAG_NOPROMISC flag
  man: ip-link: document MACVLAN/MACVTAP interface types

 ip/Makefile           |   2 +-
 ip/iplink_macvlan.c   |  68 ++++++++++++++++++++++++--------
 ip/iplink_macvtap.c   | 105 --------------------------------------------------
 man/man8/ip-link.8.in |  50 ++++++++++++++++++++++++
 4 files changed, 104 insertions(+), 121 deletions(-)
 delete mode 100644 ip/iplink_macvtap.c

-- 
2.1.2
