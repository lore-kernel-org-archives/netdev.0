From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch 1/5] Network Drop Monitor: Add netlink protocol
	identifer
Date: Wed, 11 Mar 2009 15:46:10 -0400
Message-ID: <20090311194610.GA20223@hmsreliant.think-freely.org>
References: <20090303170014.GB1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59367 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834AbZCKTqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 15:46:21 -0400
Received: from nat-pool-rdu.redhat.com ([66.187.233.202] helo=localhost)
	by smtp.tuxdriver.com with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.63)
	(envelope-from <nhorman@tuxdriver.com>)
	id 1LhUNe-00062d-NH
	for netdev@vger.kernel.org; Wed, 11 Mar 2009 15:46:19 -0400
Content-Disposition: inline
In-Reply-To: <20090303170014.GB1480@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2009 at 12:00:14PM -0500, Neil Horman wrote:
> 
> Network Drop Monitor: Add Netlink protocol identifier
>     
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
>  netlink.h |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/netlink.h b/include/linux/netlink.h
> index 1e6bf99..d4ac636 100644
> --- a/include/linux/netlink.h
> +++ b/include/linux/netlink.h
> @@ -24,6 +24,7 @@
>  /* leave room for NETLINK_DM (DM Events) */
>  #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
>  #define NETLINK_ECRYPTFS	19
> +#define NETLINK_DRPMON		20	/* Netork packet drop alerts */
>  
>  #define MAX_LINKS 32		
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


Ok, as requested by David, respinning entire set against latest net-next-2.6.
tree.  Patch 1/5, in the course of updates in this thread, is rescinded.

Neil

