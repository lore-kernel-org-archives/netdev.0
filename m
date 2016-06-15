From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/2] Two cosmetic fixes in tc/m_action.c
Date: Thu, 16 Jun 2016 00:50:37 +0200
Message-ID: <1466031039-18411-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47401 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932235AbcFOWux (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 18:50:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found these when doing something else. Shouldn't cause any functional
change.

Changes since v1:
- Replace patch 1/2 with a better solution as suggested by Stephen
  Hemminger.

Phil Sutter (2):
  tc: m_action: Use C99 style initializers for struct req
  tc: m_action: Drop unused variable nladdr in tc_action_gd()

 tc/m_action.c | 50 +++++++++++++++++++++++---------------------------
 1 file changed, 23 insertions(+), 27 deletions(-)

-- 
2.8.2
