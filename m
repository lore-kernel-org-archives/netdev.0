From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [2.6 patch] e1000e/ethtool.c: fix error checks
Date: Mon, 15 Oct 2007 09:20:55 -0700
Message-ID: <47139367.9090400@intel.com>
References: <20071014175104.GK4211@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, Jeff Garzik <jeff@garzik.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44411 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758102AbXJOQVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 12:21:36 -0400
In-Reply-To: <20071014175104.GK4211@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> You want to check for the value, not for the address.
> 
> Spotted by the Coverity checker.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> --- a/drivers/net/e1000e/ethtool.c
> +++ b/drivers/net/e1000e/ethtool.c
> @@ -1451,11 +1451,11 @@ static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
>  	}
>  
>  	*data = e1000_setup_desc_rings(adapter);
> -	if (data)
> +	if (*data)
>  		goto out;
>  
>  	*data = e1000_setup_loopback_test(adapter);
> -	if (data)
> +	if (*data)
>  		goto err_loopback;
>  
>  	*data = e1000_run_loopback_test(adapter);

I'll forward this to Jeff,

thanks.

Auke
