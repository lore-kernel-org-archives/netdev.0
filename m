From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch 1/4] lcs: convert to net_device_ops
Date: Fri, 9 Jan 2009 08:36:45 -0800
Message-ID: <20090109083645.3d2841c0@extreme>
References: <20090109090156.422658000@de.ibm.com>
	<20090109090220.554541000@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, ursula.braun@de.ibm.com
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57030 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752278AbZAIQgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 11:36:47 -0500
In-Reply-To: <20090109090220.554541000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 09 Jan 2009 10:01:57 +0100
frank.blaschka@de.ibm.com wrote:

> From: Frank Blaschka <frank.blaschka@de.ibm.com>
> 
> lcs convert to net_device_ops.
> 
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> ---
>  drivers/s390/net/lcs.c |   13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> Index: git_linus/drivers/s390/net/lcs.c
> ===================================================================
> --- git_linus.orig/drivers/s390/net/lcs.c
> +++ git_linus/drivers/s390/net/lcs.c
> @@ -2097,6 +2097,12 @@ lcs_register_netdev(struct ccwgroup_devi
>  /**
>   * lcs_new_device will be called by setting the group device online.
>   */
> +static struct net_device_ops lcs_netdev_ops = {
should be const (if it was you would catch your other problem

