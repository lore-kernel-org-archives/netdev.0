From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/15] netdevice 82596: Convert directly reference of netdev->priv
 to netdev_priv()
Date: Wed, 03 Sep 2008 09:57:19 -0400
Message-ID: <48BE97BF.7010909@garzik.org>
References: <48B3D717.7070706@cn.fujitsu.com> <48B3D7F8.6050708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43488 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140AbYICN5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 09:57:24 -0400
In-Reply-To: <48B3D7F8.6050708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  drivers/net/82596.c |   28 ++++++++++++++--------------
>  1 files changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/82596.c b/drivers/net/82596.c
> index da292e6..6b14dd2 100644
> --- a/drivers/net/82596.c
> +++ b/drivers/net/82596.c
> @@ -457,7 +457,7 @@ static inline int wait_cfg(struct net_device *dev, struct i596_cmd *cmd, int del
>  
>  static void i596_display_data(struct net_device *dev)
>  {
> -	struct i596_private *lp = dev->priv;
> +	struct i596_private *lp = dev->ml_priv;
>  	struct i596_cmd *cmd;
>  	struct i596_rfd *rfd;
>  	struct i596_rbd *rbd;
> @@ -527,7 +527,7 @@ static irqreturn_t i596_error(int irq, void *dev_id)
>  
>  static inline void init_rx_bufs(struct net_device *dev)
>  {
> -	struct i596_private *lp = dev->priv;
> +	struct i596_private *lp = dev->ml_priv;
>  	int i;
>  	struct i596_rfd *rfd;
>  	struct i596_rbd *rbd;

Your code changes and description do not match...  did you intend 
ml_priv or netdev_priv() ?


