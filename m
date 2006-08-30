From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH] WE-21 for zd1211rw
Date: Wed, 30 Aug 2006 11:55:28 -0700
Message-ID: <20060830185528.GA10032@bougret.hpl.hp.com>
References: <20060830024627.0DC5E7B40A0@zog.reactivated.net>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, netdev@vger.kernel.org, kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:52717 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1751311AbWH3S4U
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 14:56:20 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <20060830024627.0DC5E7B40A0@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2006 at 03:46:27AM +0100, Daniel Drake wrote:
> Looks like zd1211rw was forgotten from the WE-21 migration. This patch
> should do it...

	Good catch !
	Actually, I did look at it, and verified that it was using
softmac for ESSID, so I thought I was ok... With the number of driver,
I was bound to make some mistakes...
	Thanks a lot !

	Jean

> Signed-off-by: Daniel Drake <dsd@gentoo.org>
> ---
>  zd_netdev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_netdev.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_netdev.c
> +++ linux-2.6/drivers/net/wireless/zd1211rw/zd_netdev.c
> @@ -82,7 +82,7 @@ static int iw_get_nick(struct net_device
>  		       union iwreq_data *req, char *extra)
>  {
>  	strcpy(extra, "zd1211");
> -	req->data.length = strlen(extra) + 1;
> +	req->data.length = strlen(extra);
>  	req->data.flags = 1;
>  	return 0;
>  }
