From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2] diag: warn about missing first netlink attribute
Date: Thu, 28 Nov 2013 16:36:24 -0500 (EST)
Message-ID: <20131128.163624.1378587295927032601.davem@davemloft.net>
References: <20131128163816.GA32047@casper.infradead.org>
	<1385659865-1926-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718Ab3K1VgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 16:36:25 -0500
In-Reply-To: <1385659865-1926-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 28 Nov 2013 18:31:05 +0100

> The first netlink attribute (value 0) must always be defined as none/unspec.
> This is correctly done in inet_diag.h, but other diag interfaces are wrong.
> 
> Because we cannot change an existing API, I add a comment to point the mistake
> and avoid to propagate it in a new diag API in the future.
> 
> CC: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> v2: just warn about the missing attribute
> 
> If patch is approved, I will submit it when the net-next tree opens.

Indeed we can't change it, and documenting it like this is also a good
idea.

I hope Thomas agrees.
