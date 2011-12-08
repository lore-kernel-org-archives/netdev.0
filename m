From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next PATCH] net: netprio_cgroup: make net_prio_subsys static
Date: Thu, 8 Dec 2011 06:45:55 -0500
Message-ID: <20111208114555.GA1246@hmsreliant.think-freely.org>
References: <20111208051717.20236.41881.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42739 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798Ab1LHLqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 06:46:16 -0500
Content-Disposition: inline
In-Reply-To: <20111208051717.20236.41881.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 07, 2011 at 09:17:17PM -0800, John Fastabend wrote:
> net_prio_subsys can be made static this removes the sparse
> warning it was throwing.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  net/core/netprio_cgroup.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> index 3a9fd48..ea16c8f 100644
> --- a/net/core/netprio_cgroup.c
> +++ b/net/core/netprio_cgroup.c
> @@ -28,7 +28,7 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
>  static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  
> -struct cgroup_subsys net_prio_subsys = {
> +static struct cgroup_subsys net_prio_subsys = {
>  	.name		= "net_prio",
>  	.create		= cgrp_create,
>  	.destroy	= cgrp_destroy,
> 
> 

Thanks John.

Acked-by: Neil Horman <nhorman@tuxdriver.com>
