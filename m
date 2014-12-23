From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: change error message to debug message in __bond_release_one()
Date: Tue, 23 Dec 2014 09:48:38 +0800
Message-ID: <5498C9F6.70608@huawei.com>
References: <1419297876-1412-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Wengang Wang <wen.gang.wang@oracle.com>, <netdev@vger.kernel.org>,
	<gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:42968 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbaLWBsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 20:48:54 -0500
In-Reply-To: <1419297876-1412-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/12/23 9:24, Wengang Wang wrote:
> In __bond_release_one(), when the interface is not a slave or not a slave of
> "this" master, it log error message.
> 
> The message actually should be a debug message matching what bond_enslave()
> does.
> 
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> ---
>  drivers/net/bonding/bond_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 184c434..0dceba1 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1648,7 +1648,7 @@ static int __bond_release_one(struct net_device *bond_dev,
>  	/* slave is not a slave or master is not master of this slave */
>  	if (!(slave_dev->flags & IFF_SLAVE) ||
>  	    !netdev_has_upper_dev(slave_dev, bond_dev)) {
> -		netdev_err(bond_dev, "cannot release %s\n",
> +		netdev_dbg(bond_dev, "cannot release %s\n",
>  			   slave_dev->name);
>  		return -EINVAL;
>  	}
> 
Acked-by: Ding Tianhong <dingtianhong@huawei.com>
