From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: sched: remove TC_MUNGED bits
Date: Sat, 02 May 2015 22:25:31 -0400 (EDT)
Message-ID: <20150502.222531.2027100627295650417.davem@davemloft.net>
References: <1430388720-5112-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbbECCZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 22:25:33 -0400
In-Reply-To: <1430388720-5112-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 30 Apr 2015 12:12:00 +0200

> Not used.
> 
> pedit sets TC_MUNGED when packet content was altered, but all the core
> does is unset MUNGED again and then set OK2MUNGE.
> 
> And the latter isn't tested anywhere. So lets remove both
> TC_MUNGED and TC_OK2MUNGE.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
