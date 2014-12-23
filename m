From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] bonding: change error message to debug message in
 __bond_release_one()
Date: Tue, 23 Dec 2014 11:02:06 -0500
Message-ID: <20141223160206.GA37958@gospo.home.greyhouse.net>
References: <1419297876-1412-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com
To: Wengang Wang <wen.gang.wang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f68.google.com ([209.85.216.68]:44451 "EHLO
	mail-qa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756105AbaLWQCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 11:02:16 -0500
Received: by mail-qa0-f68.google.com with SMTP id dc16so1452256qab.3
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 08:02:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1419297876-1412-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 23, 2014 at 09:24:36AM +0800, Wengang Wang wrote:
> In __bond_release_one(), when the interface is not a slave or not a slave of
> "this" master, it log error message.
> 
> The message actually should be a debug message matching what bond_enslave()
> does.
> 
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

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
> -- 
> 1.8.3.1
> 
