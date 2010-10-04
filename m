From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/4] nl80211 cleanups
Date: Mon, 04 Oct 2010 21:14:02 +0200
Message-ID: <20101004191402.183055479@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:47310 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932165Ab0JDTTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 15:19:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds some new hooks to generic
netlink and then goes on to use them to really
optimise a lot of locking code in nl80211.

It not only shrinks the code in nl80211 by     
almost 5K .text, but also greatly reduces the
likelihood of future errors.

I'd prefer to merge this through John's wireless
tree, so it'd be nice to get ACKs.            

johannes

