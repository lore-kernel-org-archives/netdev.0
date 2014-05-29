From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipv6: Fix regression caused by efe4208 in udp_v6_mcast_next()
Date: Thu, 29 May 2014 20:27:04 +0000
Message-ID: <1401395226-10304-1-git-send-email-sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:40524 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbaE2U1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 16:27:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've split the last version of the patch into a fix and cleanup patch.
