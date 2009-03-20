From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] atm: lec use dev_change_mtu
Date: Fri, 20 Mar 2009 15:26:34 +0800
Message-ID: <49C3452A.8000709@cn.fujitsu.com>
References: <20090319172400.239594f8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chas@cmf.nrl.navy.mil,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52797 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751763AbZCTH1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 03:27:25 -0400
In-Reply-To: <20090319172400.239594f8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Rather than calling device pointer directly (which is incorrect with
> net_device_ops), use the standard dev_change_mtu. Compile tested only.
                                                             ^^^^^^^^^^^^Should it be dev_set_mtu?
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/net/atm/lec.c	2009-03-19 17:18:35.140652628 -0700
> +++ b/net/atm/lec.c	2009-03-19 17:19:19.500777355 -0700
> @@ -502,7 +502,7 @@ static int lec_atm_send(struct atm_vcc *
>  		priv->lane2_ops = NULL;
>  		if (priv->lane_version > 1)
>  			priv->lane2_ops = &lane2_ops;
> -		if (dev->change_mtu(dev, mesg->content.config.mtu))
> +		if (dev_set_mtu(dev, mesg->content.config.mtu))
>  			printk("%s: change_mtu to %d failed\n", dev->name,
>  			       mesg->content.config.mtu);
>  		priv->is_proxy = mesg->content.config.is_proxy;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


-- 
Regards
Yang Hongyang
