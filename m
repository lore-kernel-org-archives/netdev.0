From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/4] average: convert users to inline implementation
Date: Wed, 19 Aug 2015 09:46:18 +0200
Message-ID: <1439970382-6170-1-git-send-email-johannes@sipsolutions.net>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56381 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752687AbbHSHq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 03:46:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since there's very little benefit of the out-of-line implementation
(a single byte of .text in one driver as far as I've seen), convert
all drivers to the inline implementation, saving memory, and remove
the out-of-line implementation.

Perhaps the easiest would be for Dave to take all of these patches?

johannes
