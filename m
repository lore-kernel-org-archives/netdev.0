From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kcm: fix variable type
Date: Fri, 11 Mar 2016 11:44:42 -0500 (EST)
Message-ID: <20160311.114442.1933815095495449507.davem@davemloft.net>
References: <1457679075-22094-1-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, b.zolnierkie@samsung.com,
	m.szyprowski@samsung.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: a.hajda@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932629AbcCKQop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 11:44:45 -0500
In-Reply-To: <1457679075-22094-1-git-send-email-a.hajda@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrzej Hajda <a.hajda@samsung.com>
Date: Fri, 11 Mar 2016 07:51:15 +0100

> Function skb_splice_bits can return negative values, its result should
> be assigned to signed variable to allow correct error checking.
> 
> The problem has been detected using patch
> scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci.
> 
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Since skb_splice_bits() returns an 'int', that would be a more appropriate
type to use here.

Thank you.
