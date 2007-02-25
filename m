From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/7] cxgb3 - FW version update
Date: Sun, 25 Feb 2007 14:48:32 -0500
Message-ID: <45E1E810.2000706@garzik.org>
References: <20070225004401.20831.3292.stgit@localhost.localdomain> <1172431719.4717.8.camel@stevo-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34403 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932244AbXBYTsr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Feb 2007 14:48:47 -0500
In-Reply-To: <1172431719.4717.8.camel@stevo-laptop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> Hey Divy,
> 
> You missed a printk change.  Here is an updated patch.
> 
> ------------
> 
> Update FW version to 3.2
> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---
> 
>  drivers/net/cxgb3/t3_hw.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
> index 365a7f5..08a6295 100644
> --- a/drivers/net/cxgb3/t3_hw.c
> +++ b/drivers/net/cxgb3/t3_hw.c
> @@ -884,11 +884,11 @@ int t3_check_fw_version(struct adapter *
>  	major = G_FW_VERSION_MAJOR(vers);
>  	minor = G_FW_VERSION_MINOR(vers);
>  
> -	if (type == FW_VERSION_T3 && major == 3 && minor == 1)
> +	if (type == FW_VERSION_T3 && major == 3 && minor == 2)
>  		return 0;
>  
>  	CH_ERR(adapter, "found wrong FW version(%u.%u), "
> -	       "driver needs version 3.1\n", major, minor);
> +	       "driver needs version 3.2\n", major, minor);

I would rather fix the code to use constants, and thus avoid this 
problem ever happening again.

	Jeff



