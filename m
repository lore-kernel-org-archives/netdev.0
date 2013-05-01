From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch 1/1] ipvs: change type of netns_ipvs->sysctl_sync_qlen_max
Date: Wed, 1 May 2013 17:51:31 +0900
Message-ID: <20130501085131.GB30727@verge.net.au>
References: <20130429185510.DFBB031C266@corp2gmr1-1.hot.corp.google.com>
 <20130430022417.GA24214@verge.net.au>
 <20130430.002244.1149700663501203988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	zhangyanfei@cn.fujitsu.com, ja@ssi.bg
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49563 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756284Ab3EAIvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 04:51:35 -0400
Content-Disposition: inline
In-Reply-To: <20130430.002244.1149700663501203988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 12:22:44AM -0400, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Tue, 30 Apr 2013 11:24:17 +0900
> 
> > On Mon, Apr 29, 2013 at 11:55:10AM -0700, akpm@linux-foundation.org wrote:
> >> From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> >> Subject: ipvs: change type of netns_ipvs->sysctl_sync_qlen_max
> >> 
> >> This member of struct netns_ipvs is calculated from nr_free_buffer_pages
> >> so change its type to unsigned long in case of overflow.  Also, type of
> >> its related proc var sync_qlen_max and the return type of function
> >> sysctl_sync_qlen_max() should be changed to unsigned long, too.
> >> 
> >> Besides, the type of ipvs_master_sync_state->sync_queue_len should be
> >> changed to unsigned long accordingly.
> >> 
> >> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> >> Cc: Simon Horman <horms@verge.net.au>
> >> Cc: Julian Anastasov <ja@ssi.bg>
> >> Cc: David Miller <davem@davemloft.net>
> >> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Andrew, David,
> > 
> > It seems most appropriate for me to
> > queue this up for v3.11 in the ipvs-next tree.
> > 
> > Is that fine?
> 
> I'm personally fine with that.


Thanks, queued-up accordingly.
