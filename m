From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH] wavelan: fix section mismatch
Date: Thu, 25 May 2006 11:39:49 -0700
Message-ID: <20060525183949.GA23930@bougret.hpl.hp.com>
References: <20060525110921.afaa98ce.rdunlap@xenotime.net>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tayrelbas04.tay.hp.com ([161.114.80.247]:56709 "EHLO
	tayrelbas04.tay.hp.com") by vger.kernel.org with ESMTP
	id S1030320AbWEYSjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 14:39:52 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Content-Disposition: inline
In-Reply-To: <20060525110921.afaa98ce.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 25, 2006 at 11:09:21AM -0700, Randy.Dunlap wrote:
> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Fix section mismatch warning:
> WARNING: drivers/net/wireless/wavelan.o - Section mismatch: reference to
> .init.text: from .text between 'init_module' (at offset 0x371e) and
> 'cleanup_module'
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

	I did not check that kernel, but it seems a no brainer. Would
you mind sending to John Linville or Jeff Garzik as I'm about to go on
vacvation.
	Thanks !

	Jean


> ---
>  drivers/net/wireless/wavelan.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2617-rc5.orig/drivers/net/wireless/wavelan.c
> +++ linux-2617-rc5/drivers/net/wireless/wavelan.c
> @@ -4306,7 +4306,7 @@ out:
>   * Insertion of the module
>   * I'm now quite proud of the multi-device support.
>   */
> -int init_module(void)
> +int __init init_module(void)
>  {
>  	int ret = -EIO;		/* Return error if no cards found */
>  	int i;
> 
> 
> ---
