From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH 06/10] drivers/net/usb: Remove unnecessary casts of
 netdev_priv
Date: Tue, 16 Nov 2010 19:59:29 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1011161958320.1392@gabi>
References: <cover.1289855436.git.joe@perches.com> <66a3d7996e4ce8a84610237e86adf4b15a48514a.1289855436.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jiri Kosina <trivial@kernel.org>,
	Petko Manolov <petkan@users.sourceforge.net>,
	Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([78.83.248.164]:47077 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754516Ab0KPQjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 11:39:35 -0500
In-Reply-To: <66a3d7996e4ce8a84610237e86adf4b15a48514a.1289855436.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ACK! :-)


 		Petko


On Mon, 15 Nov 2010, Joe Perches wrote:

> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> drivers/net/usb/pegasus.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index 6710f093..ef36676 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -359,7 +359,7 @@ fail:
>
> static int mdio_read(struct net_device *dev, int phy_id, int loc)
> {
> -	pegasus_t *pegasus = (pegasus_t *) netdev_priv(dev);
> +	pegasus_t *pegasus = netdev_priv(dev);
> 	u16 res;
>
> 	read_mii_word(pegasus, phy_id, loc, &res);
> @@ -397,7 +397,7 @@ fail:
>
> static void mdio_write(struct net_device *dev, int phy_id, int loc, int val)
> {
> -	pegasus_t *pegasus = (pegasus_t *) netdev_priv(dev);
> +	pegasus_t *pegasus = netdev_priv(dev);
>
> 	write_mii_word(pegasus, phy_id, loc, val);
> }
> -- 
> 1.7.3.1.g432b3.dirty
>
>
