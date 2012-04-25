From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 0/2] ipvs: netns avoid crash at netns init
Date: Wed, 25 Apr 2012 09:43:39 +0200
Message-ID: <1335339821-29684-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: <horms@verge.net.au>, <ja@ssi.bg>, <wensong@linux-vs.org>,
	<lvs-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:44113 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534Ab2DYHnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 03:43:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two simple patches that avoid crashes for no memory at netns init.

- Check return value of protocoll init.
- Null check of net-ipvs in shedulers.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
-- 
1.7.2.3
