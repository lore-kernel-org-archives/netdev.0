From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fib: Restore NTF_ROUTER exception in fib6_age()
Date: Thu, 07 Jun 2012 13:03:11 -0700 (PDT)
Message-ID: <20120607.130311.920828145290724774.davem@davemloft.net>
References: <6e43964ac82665f0257ac4f53c17b3b3403edcc3.1339087863.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45319 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501Ab2FGUDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:03:12 -0400
In-Reply-To: <6e43964ac82665f0257ac4f53c17b3b3403edcc3.1339087863.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu,  7 Jun 2012 18:51:04 +0200

> Commit 5339ab8b1dd82 (ipv6: fib: Convert fib6_age() to
> dst_neigh_lookup().) seems to have mistakenly inverted the
> exception for cached NTF_ROUTER routes.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Thanks for fixing this, applied.
