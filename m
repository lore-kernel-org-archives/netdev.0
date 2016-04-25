From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] pskb_extract() helper function.
Date: Mon, 25 Apr 2016 16:54:43 -0400 (EDT)
Message-ID: <20160425.165443.811025678894769195.davem@davemloft.net>
References: <cover.1461368732.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com, eric.dumazet@gmail.com,
	marcelo.leitner@gmail.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964911AbcDYUyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 16:54:46 -0400
In-Reply-To: <cover.1461368732.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri, 22 Apr 2016 18:36:34 -0700

> This patchset follows up on the discussion in
>  https://www.mail-archive.com/netdev@vger.kernel.org/msg105090.html
> 
> For RDS-TCP, we have to deal with the full gamut of
> nonlinear sk_buffs, including all the frag_list variants.
> Also, the parent skb has to remain unchanged, while the clone
> is queued for Rx on the PF_RDS socket. 
> 
> Patch 1 of this patchset adds a pskb_extract() function that 
> does all this without the redundant memcpy's in pskb_expand_head() 
> and __pskb_pull_tail().
> 
> v2: Marcelo Leitner review comments

Series applied, thanks.
