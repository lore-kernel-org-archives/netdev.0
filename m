From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Documentation: add a guideline for hard_start_xmit method
 not to modify SKB
Date: Sat, 12 Jan 2008 17:27:12 -0500
Message-ID: <47893EC0.1080303@pobox.com>
References: <110604.81450.qm@web52011.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34069 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755107AbYALW1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 17:27:14 -0500
In-Reply-To: <110604.81450.qm@web52011.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matti Linnanvuori wrote:
> From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
> 
> Add a guideline for hard_start_xmit method not to
> modify SKB.
> 
> Signed-off-by: Matti Linnanvuori
> <mattilinnanvuori@yahoo.com>
> 
> ---
> 
> 
> --- a/Documentation/networking/driver.txt	2007-12-22
> 18:50:28.062169500 +0200
> +++ b/Documentation/networking/driver.txt	2007-12-22
> 19:10:58.726566000 +0200
> 
> @@ -74,6 +74,9 @@ Transmit path guidelines:
>     If you return 1 from the hard_start_xmit method,
> you must not keep
>     any reference to that SKB and you must not attempt
> to free it up.
>  
> +4) A hard_start_xmit method must not modify the
> cloned parts of the
> +   SKB.
> +
>  Probing guidelines:
>  
>  1) Any hardware layer address you obtain for your
> device should
> 

patch is word-wrapped


