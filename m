From: David Miller <davem@davemloft.net>
Subject: Re: [RFC V3 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Mon, 20 Feb 2012 00:54:51 -0500 (EST)
Message-ID: <20120220.005451.548532173290909435.davem@davemloft.net>
References: <20120216235218.6381.51539.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932Ab2BTFyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 00:54:53 -0500
In-Reply-To: <20120216235218.6381.51539.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Thu, 16 Feb 2012 15:52:18 -0800

> +	for (h = 0; h < NETDEV_HASHENTRIES; h++) {
> +		head = &net->dev_index_head[h];
> +		hlist_for_each_entry_rcu(dev, node, head, index_hlist) {

list_for_each_entry_rcu(dev, &net->dev_base_head, dev_list)
