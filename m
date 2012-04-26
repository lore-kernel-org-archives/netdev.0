From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [v2 PATCH 0/2] ipvs: netns avoid crash at netns init
Date: Thu, 26 Apr 2012 09:45:33 +0200
Message-ID: <1335426335-5093-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: <horms@verge.net.au>, <ja@ssi.bg>, <wensong@linux-vs.org>,
	<lvs-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:61650 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982Ab2DZHpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 03:45:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two simple patches that avoid crashes for no memory at netns init.

- Check return value of protocoll init.
- Null check of net-ipvs in shedulers.


Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
-- 
1.7.2.3
