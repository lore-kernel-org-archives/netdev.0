From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Remove unused variables in rt_cache_stat
Date: Mon, 30 Jul 2012 14:52:20 -0700 (PDT)
Message-ID: <20120730.145220.328852279916272895.davem@davemloft.net>
References: <1343684750-2987-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819Ab2G3VwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 17:52:21 -0400
In-Reply-To: <1343684750-2987-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Mon, 30 Jul 2012 14:45:50 -0700

> With the removal of the routing cache, some variables in rt_cache_stat are no
> longer used. Remove them from rt_cache_stat and do not print them out in
> /proc/net/stat/rt_cache.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
> checkpatch complains that the seq_printf line is over 80 chars which was already
> the case. I left it as is to aid in grepping the sources. 

You cannot make this change, these fields are exported via procfs and
therefore you will break any application that is parsing the existing
layout.
