From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] net: make TCP preemptible
Date: Fri, 29 Apr 2016 16:39:58 -0400 (EDT)
Message-ID: <20160429.163958.6363647244164609.davem@davemloft.net>
References: <1461899449-8096-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, ast@fb.com,
	marcelo.leitner@gmail.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbcD2UkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 16:40:01 -0400
In-Reply-To: <1461899449-8096-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu, 28 Apr 2016 20:10:42 -0700

> Most of TCP stack assumed it was running from BH handler.

Assuming you are respinning this to fix that stats bumping typo.

You should really look into how that got corrupted. :)
