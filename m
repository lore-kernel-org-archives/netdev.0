From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 3/3] net: neterion: Do not break word unregister.
Date: Fri, 02 Nov 2012 23:43:45 +0900
Message-ID: <5093DC21.30004@linux-ipv6.org>
References: <201211021439.qA2EdkbO004741@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46773 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754862Ab2KBOnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 10:43:47 -0400
In-Reply-To: <201211021439.qA2EdkbO004741@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, subject and date are strange.  I'm resending...

--yoshfuji

YOSHIFUJI Hideaki wrote:
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  drivers/net/ethernet/neterion/s2io.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
> index de50547..c98decb 100644
> --- a/drivers/net/ethernet/neterion/s2io.c
> +++ b/drivers/net/ethernet/neterion/s2io.c
> @@ -8239,7 +8239,8 @@ static int __init s2io_starter(void)
>  
>  /**
>   * s2io_closer - Cleanup routine for the driver
> - * Description: This function is the cleanup routine for the driver. It unregist * ers the driver.
> + * Description: This function is the cleanup routine for the driver. It
> + * unregisters the driver.
>   */
>  
>  static __exit void s2io_closer(void)
> 
