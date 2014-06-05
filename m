From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bridge: Fix incorrect judgment of promisc
Date: Thu, 05 Jun 2014 15:21:51 -0700 (PDT)
Message-ID: <20140605.152151.1874961526019573838.davem@davemloft.net>
References: <1401969212-19193-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, David.Laight@ACULAB.COM,
	vyasevic@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbaFEWVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:21:52 -0400
In-Reply-To: <1401969212-19193-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Thu,  5 Jun 2014 20:53:32 +0900

> br_manage_promisc() incorrectly expects br_auto_port() to return only 0
> or 1, while it actually returns flags, i.e., a subset of BR_AUTO_MASK.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

I'm applying this as-is for now, even though I saw the other
suggestions in this thread (which BTW didn't get picked up by
patchwork, maybe some of you dropped the Message-Id in your replies by
accident).
