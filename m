From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [patch] sctp: use the passed in gfp flags instead GFP_KERNEL
Date: Fri, 1 Mar 2013 09:35:17 -0500
Message-ID: <20130301143517.GA1523@hmsreliant.think-freely.org>
References: <20130301052743.GD2669@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53801 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab3CAOff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 09:35:35 -0500
Content-Disposition: inline
In-Reply-To: <20130301052743.GD2669@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 01, 2013 at 08:27:43AM +0300, Dan Carpenter wrote:
> This patch doesn't change how the code works because in the current
> kernel gfp is always GFP_KERNEL.  But gfp was obviously intended
> instead of GFP_KERNEL.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index 2b3ef03..12ed45d 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -155,7 +155,7 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
>  
>  	/* SCTP-AUTH extensions*/
>  	INIT_LIST_HEAD(&ep->endpoint_shared_keys);
> -	null_key = sctp_auth_shkey_create(0, GFP_KERNEL);
> +	null_key = sctp_auth_shkey_create(0, gfp);
>  	if (!null_key)
>  		goto nomem;
>  
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
