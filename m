From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch v3] Documentation: add a guideline for hard_start_xmit
 method
Date: Fri, 18 Jan 2008 14:42:13 -0500
Message-ID: <47910115.2030102@pobox.com>
References: <492102.15643.qm@web52012.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52301 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759075AbYARTmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 14:42:17 -0500
In-Reply-To: <492102.15643.qm@web52012.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matti Linnanvuori wrote:
> From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
> 
> Add a guideline not to modify SKBs.
> 
> Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
> 
> ---
> 
> --- a/Documentation/networking/driver.txt 2008-01-13 07:14:01.608291500 +0200
> +++ b/Documentation/networking/driver.txt 2008-01-15 16:16:14.636054000 +0200
> @@ -61,7 +61,10 @@ Transmit path guidelines:
>  2) Do not forget to update netdev->trans_start to jiffies after
>     each new tx packet is given to the hardware.
>  
> -3) Do not forget that once you return 0 from your hard_start_xmit
> +3) A hard_start_xmit method must not modify the shared parts of a
> +   cloned SKB.
> +
> +4) Do not forget that once you return 0 from your hard_start_xmit
>     method, it is your driver's responsibility to free up the SKB
>     and in some finite amount of time.

applied


