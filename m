From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [Patch 1/5] Network Drop Monitor: Add netlink protocol identifer
Date: Tue, 3 Mar 2009 21:20:06 +0300
Message-ID: <20090303182006.GB29236@ioremap.net>
References: <20090303170014.GB1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:59422 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752399AbZCCSUM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2009 13:20:12 -0500
Content-Disposition: inline
In-Reply-To: <20090303170014.GB1480@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil.

On Tue, Mar 03, 2009 at 12:00:14PM -0500, Neil Horman (nhorman@tuxdriver.com) wrote:
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

Why do you want to use own family instead of using existing netlink
helpers like connector or genetlink?

-- 
	Evgeniy Polyakov
