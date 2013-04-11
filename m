From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] netprio_cgroup: make local table static
Date: Thu, 11 Apr 2013 09:22:07 -0400
Message-ID: <20130411132207.GA8986@neilslaptop.think-freely.org>
References: <20130410135605.0431e7aa@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53019 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab3DKNWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 09:22:20 -0400
Content-Disposition: inline
In-Reply-To: <20130410135605.0431e7aa@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 10, 2013 at 01:56:05PM -0700, Stephen Hemminger wrote:
> Minor sparse warning
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> --- a/net/core/netprio_cgroup.c	2013-04-10 13:36:56.928429191 -0700
> +++ b/net/core/netprio_cgroup.c	2013-04-10 13:37:04.516330753 -0700
> @@ -247,7 +247,7 @@ static struct cftype ss_files[] = {
>  	{ }	/* terminate */
>  };
>  
> -struct cgroup_subsys net_prio_subsys = {
> +static struct cgroup_subsys net_prio_subsys = {
>  	.name		= "net_prio",
>  	.css_alloc	= cgrp_css_alloc,
>  	.css_online	= cgrp_css_online,
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
