From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: mlx4_en: remove duplicated #include
Date: Mon, 27 Oct 2008 14:52:49 -0400
Message-ID: <49060E01.4020904@pobox.com>
References: <2a61071b0810260805o17e78c73q38d133d83e2f5ea8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rolandd@cisco.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: Huang Weiyi <weiyi.huang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53122 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753208AbYJ0SxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 14:53:05 -0400
In-Reply-To: <2a61071b0810260805o17e78c73q38d133d83e2f5ea8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Huang Weiyi wrote:
> Removed duplicated #include <linux/cpumask.h> in
> drivers/net/mlx4/en_main.c.
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com 
> <mailto:weiyi.huang@gmail.com>>
> 
> diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
> index 1b0eebf..4b9794e 100644
> --- a/drivers/net/mlx4/en_main.c
> +++ b/drivers/net/mlx4/en_main.c
> @@ -35,7 +35,6 @@
>  #include <linux/module.h>
>  #include <linux/delay.h>
>  #include <linux/netdevice.h>
> -#include <linux/cpumask.h>

applied


