From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] Minor ss filter fix and review
Date: Wed, 13 Apr 2016 22:07:03 +0200
Message-ID: <1460578025-12224-1-git-send-email-phil@nwl.cc>
References: <20160329193242.GA28502@orbyte.nwl.cc>
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:56976 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231AbcDMUHV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 16:07:21 -0400
In-Reply-To: <20160329193242.GA28502@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking for a solution to the problem described in patch 2/2, I
discovered the overly complicated assignment in filter_states_set() which
is simplified in patch 1/2.

Phil Sutter (2):
  ss: Drop silly assignment
  ss: Fix accidental state filter override

 misc/ss.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

-- 
2.8.0
