From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/3] add numa node information to struct device
Date: Wed, 15 Nov 2006 15:15:35 -0800
Message-ID: <20061115151535.ef1beadb.akpm@osdl.org>
References: <20061115173701.GB18244@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46774 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162053AbWKOXPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 18:15:47 -0500
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20061115173701.GB18244@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Nov 2006 18:37:01 +0100
Christoph Hellwig <hch@lst.de> wrote:

> +#ifdef CONFIG_NUMA
> +#define dev_to_node(dev)	((dev)->numa_node)
> +#define set_dev_node(dev, node)	((dev)->numa_node = node)
> +#else
> +#define dev_to_node(dev)	(-1)
> +#define set_dev_node(dev, node)	do { } while (0)
> +#endif

minor point: using inlines here would give typechecking, prevent possible
unused-var warnings, etc.

Maybe there was a reason for not doing that.

<does it>

No doubt I'll find out ;)
