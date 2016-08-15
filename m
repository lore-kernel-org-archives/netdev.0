From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable: avoid large lock-array allocations
Date: Sun, 14 Aug 2016 21:14:13 -0700 (PDT)
Message-ID: <20160814.211413.1040741676547676407.davem@davemloft.net>
References: <1470996232-16558-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbcHOEOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 00:14:14 -0400
In-Reply-To: <1470996232-16558-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 12 Aug 2016 12:03:52 +0200

> Sander reports following splat after netfilter nat bysrc table got
> converted to rhashtable:

Just to be clear I did apply this version.

Please put something like "v2" or similar in your subject lines in
the future, that'll make it easy for me.
