From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: remove checks around dev_kfree_skb() calls
Date: Wed, 02 Jul 2014 17:38:03 -0700 (PDT)
Message-ID: <20140702.173803.1384383650865317087.davem@davemloft.net>
References: <201406280410.01146.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbaGCAiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 20:38:05 -0400
In-Reply-To: <201406280410.01146.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 28 Jun 2014 04:10:00 +0400

> Since consume_skb() (and hence dev_kfree_skb() macro) checks the passed pointer
> for NULL, there's no need to check for NULL before invoking dev_kfree_skb().
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
