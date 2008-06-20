From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/8] ipv6: Check return of dev_set_allmulti
Date: Thu, 19 Jun 2008 19:09:11 -0700 (PDT)
Message-ID: <20080619.190911.117307969.davem@davemloft.net>
References: <485AFFFB.5040901@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, kaber@trash.net
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751133AbYFTCJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 22:09:11 -0400
In-Reply-To: <485AFFFB.5040901@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 20 Jun 2008 08:55:23 +0800

> @@ -632,7 +633,10 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
>  		return -EINVAL;
>  	}
>  
> -	dev_set_allmulti(dev, 1);
> +	/* Check whether allmulti overflow */
> +	err = dev_set_allmulti(dev, 1);
> +	if (err)
> +		return err;

Please delete comment.
