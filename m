From: Florian Westphal <fw@strlen.de>
Subject: [PATCH stable 3.4.y 0/2] gso/gro forwarding changeset
Date: Sat, 22 Feb 2014 10:33:24 +0100
Message-ID: <1393061606-5422-1-git-send-email-fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44046 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751536AbaBVJhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 04:37:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dropped the 2nd patch of the series (addition of netif_skb_dev_features)
for the longterm-backport.

The forward path will use 0 feature mask instead.
I think it is preferable to keep the changeset smaller for these kernels.

Should apply to 3.2.y as well.

Let me know if you disagree and would like to have netif_skb_dev_features
backport too.
