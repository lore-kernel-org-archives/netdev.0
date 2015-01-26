From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] rhashtable: rhashtable_remove() must
 unlink in both tbl and future_tbl
Date: Mon, 26 Jan 2015 11:57:04 -0800 (PST)
Message-ID: <20150126.115704.1748957006917820310.davem@davemloft.net>
References: <20150120165826.GK20315@casper.infradead.org>
	<54BEA1F9.1050908@cogentembedded.com>
	<20150121115401.GA12570@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, ying.xue@windriver.com,
	richard.alpe@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44843 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120AbbAZT5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 14:57:07 -0500
In-Reply-To: <20150121115401.GA12570@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 21 Jan 2015 11:54:01 +0000

> As removals can occur during resizes, entries may be referred to from
> both tbl and future_tbl when the removal is requested. Therefore
> rhashtable_remove() must unlink the entry in both tables if this is
> the case. The existing code did search both tables but stopped when it
> hit the first match.
> 
> Failing to unlink in both tables resulted in use after free.
> 
> Fixes: 97defe1ecf86 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
> Reported-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> v2: 12 digit commit reference, commit msg clarification as pointed
>     out by Sergei.

Applied, thanks.
