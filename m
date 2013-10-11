From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wimax: Use WARN(1,...) rather than printk followed by
 WARN_ON(1)
Date: Fri, 11 Oct 2013 14:38:23 -0400 (EDT)
Message-ID: <20131011.143823.1482605672848878474.davem@davemloft.net>
References: <1381192238-6486-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
	wimax@linuxwimax.org, netdev@vger.kernel.org,
	duanj.fnst@cn.fujitsu.com
To: djduanjiong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53770 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295Ab3JKSiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 14:38:25 -0400
In-Reply-To: <1381192238-6486-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: djduanjiong@gmail.com
Date: Mon,  7 Oct 2013 17:30:38 -0700

> -	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node) {
> -		printk(KERN_ERR "BUG: %s wimax_dev %p ifindex %d not cleared\n",
> +	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node)
> +		WARN(1, KERN_ERR "BUG: %s wimax_dev %p ifindex %d not cleared\n",
>  		       __func__, wimax_dev, wimax_dev->net_dev->ifindex);


You are changing the column where the openning parenthesis appears by
changing the printk() into a WARN(), therefore you have to adjust the
indentation of the next line such that the arguments start at the first
column after the openning parenthesis.
