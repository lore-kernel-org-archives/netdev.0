From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 3/3] xen-netback: reduce log spam
Date: Thu, 10 Mar 2016 17:23:36 +0000
Message-ID: <20160310172336.GP31271@citrix.com>
References: <1457613028-10381-1-git-send-email-paul.durrant@citrix.com>
 <1457613028-10381-4-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22801 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753448AbcCJRX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 12:23:27 -0500
Content-Disposition: inline
In-Reply-To: <1457613028-10381-4-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 12:30:28PM +0000, Paul Durrant wrote:
> Remove the "prepare for reconnect" pr_info in xenbus.c. It's largely
> uninteresting and the states of the frontend and backend can easily be
> observed by watching the (o)xenstored log.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netback/xenbus.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 39a303d..bd182cd 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -511,8 +511,6 @@ static void set_backend_state(struct backend_info *be,
>  			switch (state) {
>  			case XenbusStateInitWait:
>  			case XenbusStateConnected:
> -				pr_info("%s: prepare for reconnect\n",
> -					be->dev->nodename);
>  				backend_switch_state(be, XenbusStateInitWait);
>  				break;
>  			case XenbusStateClosing:
> -- 
> 2.1.4
> 
