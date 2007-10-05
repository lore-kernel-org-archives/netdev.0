From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: fix debugging printout code
Date: Fri, 05 Oct 2007 13:53:51 -0400
Message-ID: <47067A2F.5020603@garzik.org>
References: <20071004183843.31540.23710.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47847 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757449AbXJERxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 13:53:53 -0400
In-Reply-To: <20071004183843.31540.23710.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> A small bug crawled in the -DDEBUG enabled code. Fix this to
> properly call the backreference device name.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/hw.h     |    2 +-
>  drivers/net/e1000e/netdev.c |    4 +---
>  2 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
> index 848217a..aa82f1a 100644
> --- a/drivers/net/e1000e/hw.h
> +++ b/drivers/net/e1000e/hw.h
> @@ -852,7 +852,7 @@ struct e1000_hw {
>  
>  #ifdef DEBUG
>  #define hw_dbg(hw, format, arg...) \
> -	printk(KERN_DEBUG, "%s: " format, e1000_get_hw_dev_name(hw), ##arg);
> +	printk(KERN_DEBUG, "%s: " format, e1000e_get_hw_dev_name(hw), ##arg);

I will apply this, but, I strongly encourage deletion of this in favor 
of the existing dev_dbg()

	Jeff



