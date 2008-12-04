From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH next] sgi-xp: Kill directly reference of netdev->priv
Date: Thu, 4 Dec 2008 15:41:15 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812041538330.26947@wrl-59.cs.helsinki.fi>
References: <4937D38F.6010102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54669 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbYLDNlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 08:41:18 -0500
In-Reply-To: <4937D38F.6010102@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Dec 2008, Wang Chen wrote:

> Simply replace netdev->priv with netdev_priv().
> 
> Not do compile test, because no IA64 or x86_64 box.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  drivers/misc/sgi-xp/xpnet.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
> index 71513b3..9e5233a 100644
> --- a/drivers/misc/sgi-xp/xpnet.c
> +++ b/drivers/misc/sgi-xp/xpnet.c
> @@ -154,7 +154,7 @@ xpnet_receive(short partid, int channel, struct xpnet_message *msg)
>  	void *dst;
>  	enum xp_retval ret;
>  	struct xpnet_dev_private *priv =
> -	    (struct xpnet_dev_private *)xpnet_device->priv;
> +	    (struct xpnet_dev_private *)netdev_priv(xpnet_device);

netdev_priv returns void, so these casts seem unnecessary here & other 
places belwo (which I cut)...


-- 
 i.
