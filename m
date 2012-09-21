From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: use <linux/export.h> instead of
 <linux/module.h>
Date: Fri, 21 Sep 2012 15:44:07 -0400 (EDT)
Message-ID: <20120921.154407.1394423871025757033.davem@davemloft.net>
References: <1348256138-15500-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52362 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757555Ab2IUToJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 15:44:09 -0400
In-Reply-To: <1348256138-15500-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Fri, 21 Sep 2012 21:35:38 +0200

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Since (9f00d97 netlink: hide struct module parameter in netlink_kernel_create),
> linux/netlink.h includes linux/module.h because of the use of THIS_MODULE.
> 
> Use linux/export.h instead, as suggested by Stephen Rothwell, which is
> significantly smaller and defines THIS_MODULES.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied, but please make explicit what tree you are targetting when you
submit changes like this in the future.

Thanks.
