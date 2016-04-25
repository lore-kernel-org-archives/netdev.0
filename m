From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] soreuseport: Resolve merge conflict for v4/v6
 ordering fix
Date: Mon, 25 Apr 2016 13:28:22 -0400 (EDT)
Message-ID: <20160425.132822.1730357626652084511.davem@davemloft.net>
References: <1461595332-16994-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932691AbcDYR21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 13:28:27 -0400
In-Reply-To: <1461595332-16994-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Mon, 25 Apr 2016 10:42:12 -0400

> From: Craig Gallek <kraig@google.com>
> 
> d894ba18d4e4 ("soreuseport: fix ordering for mixed v4/v6 sockets")
> was merged as a bug fix to the net tree.  Two conflicting changes
> were committed to net-next before the above fix was merged back to
> net-next:
> ca065d0cf80f ("udp: no longer use SLAB_DESTROY_BY_RCU")
> 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")
> 
> These changes switched the datastructure used for TCP and UDP sockets
> from hlist_nulls to hlist.  This patch applies the necessary parts
> of the net tree fix to net-next which were not automatic as part of the
> merge.
> 
> Fixes: 1602f49b58ab ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied, thanks for taking care of this Craig.
