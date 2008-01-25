From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 03/14] [rndis_host] Use 1KB buffer in rndis_unbind
Date: Thu, 24 Jan 2008 16:55:07 -0800
Message-ID: <200801241655.07802.david-b@pacbell.net>
References: <20080120001359.25718.20460.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, bjd@jooz.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:36370 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754120AbYAYBUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 20:20:20 -0500
In-Reply-To: <20080120001359.25718.20460.stgit@fate.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 19 January 2008, Jussi Kivilinna wrote:
> rndis_command requires the caller to pass in a buffer of at least 1KB.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Signed-off-by: Bjorge Dijkstra <bjd@jooz.net>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

> ---
> 
>  drivers/net/usb/rndis_host.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index 96ef6a9..42b161c 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -577,7 +577,7 @@ static void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
>  	struct rndis_halt	*halt;
>  
>  	/* try to clear any rndis state/activity (no i/o from stack!) */
> -	halt = kzalloc(sizeof *halt, GFP_KERNEL);
> +	halt = kzalloc(CONTROL_BUFFER_SIZE, GFP_KERNEL);
>  	if (halt) {
>  		halt->msg_type = RNDIS_MSG_HALT;
>  		halt->msg_len = ccpu2(sizeof *halt);
> 


