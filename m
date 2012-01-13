From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH 1/6] netback: page pool version 1
Date: Fri, 13 Jan 2012 12:37:46 -0500
Message-ID: <20120113173746.GA16182@phenom.dumpdata.com>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
 <1326473949-22389-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ian.campbell@citrix.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:21550 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932429Ab2AMRjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 12:39:45 -0500
Content-Disposition: inline
In-Reply-To: <1326473949-22389-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static idx_t free_head;
> +static int free_count;
> +static unsigned long pool_size;
> +static DEFINE_SPINLOCK(pool_lock);
> +static struct page_pool_entry *pool;
> +
> +static int get_free_entry(void)
> +{
> +	unsigned long flag;
> +	int idx;
> +
> +	spin_lock_irqsave(&pool_lock, flag);

What is the benfit of using the irq version of the spinlock instead
of the normal one??
