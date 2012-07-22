From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix race condition in several drivers when
 reading stats
Date: Sun, 22 Jul 2012 12:12:52 -0700 (PDT)
Message-ID: <20120722.121252.1434955686463276273.davem@davemloft.net>
References: <1342888250-28352-1-git-send-email-kgroeneveld@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kgroeneveld@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455Ab2GVTMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 15:12:52 -0400
In-Reply-To: <1342888250-28352-1-git-send-email-kgroeneveld@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Groeneveld <kgroeneveld@gmail.com>
Date: Sat, 21 Jul 2012 12:30:50 -0400

> Fix race condition in several network drivers when reading stats on 32bit
> UP architectures.  These drivers update their stats in a BH context and
> therefore should use u64_stats_fetch_begin_bh/u64_stats_fetch_retry_bh
> instead of u64_stats_fetch_begin/u64_stats_fetch_retry when reading the
> stats.
> 
> Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>

Applied, thanks.
