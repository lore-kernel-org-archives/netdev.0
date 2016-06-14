From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] Two cosmetic fixes in tc/m_action.c
Date: Wed, 15 Jun 2016 00:26:07 +0200
Message-ID: <1465943169-4101-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41528 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932124AbcFNW0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 18:26:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found these when doing something else. Shouldn't cause any functional
change.

Phil Sutter (2):
  tc: m_action: Fix for field init before memset
  tc: m_action: Drop unused variable nladdr in tc_action_gd()

 tc/m_action.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

-- 
2.8.2
