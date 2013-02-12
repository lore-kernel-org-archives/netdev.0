From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] checksum: remove duplicated line of code in csum_fold
Date: Tue, 12 Feb 2013 12:12:35 -0500 (EST)
Message-ID: <20130212.121235.1398926681356889354.davem@davemloft.net>
References: <1360689003-21794-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933463Ab3BLRMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 12:12:37 -0500
In-Reply-To: <1360689003-21794-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Tue, 12 Feb 2013 18:10:03 +0100

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

I am very sure that those two lines are there intentionally.
The first addition one can overflow, therefore we need to
fold again (which cannot overflow).
