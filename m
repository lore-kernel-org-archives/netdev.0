From: "John W. Linville" <linville@tuxdriver.com>
Subject: Just "[PATCH]..." -- Re: [PATCH 1/5] rndis_host: support
	ETHTOOL_GPERMADDR
Date: Tue, 6 Oct 2009 17:39:25 -0400
Message-ID: <20091006213924.GE2911@tuxdriver.com>
References: <1254863142-14698-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50702 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933088AbZJFVqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 17:46:40 -0400
Received: from uucp by smtp.tuxdriver.com with local-rmail (Exim 4.63)
	(envelope-from <linville@tuxdriver.com>)
	id 1MvHrA-0002Vk-E5
	for netdev@vger.kernel.org; Tue, 06 Oct 2009 17:46:04 -0400
Received: from linville-t400.local (linville-t400.local [127.0.0.1])
	by linville-t400.local (8.14.3/8.14.3) with ESMTP id n96LdP7Z017167
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2009 17:39:25 -0400
Received: (from linville@localhost)
	by linville-t400.local (8.14.3/8.14.3/Submit) id n96LdP8m017166
	for netdev@vger.kernel.org; Tue, 6 Oct 2009 17:39:25 -0400
Content-Disposition: inline
In-Reply-To: <1254863142-14698-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 06, 2009 at 05:05:42PM -0400, John W. Linville wrote:
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
>  drivers/net/usb/rndis_host.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index d032bba..0caa800 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -418,6 +418,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
>  		goto halt_fail_and_release;
>  	}
>  	memcpy(net->dev_addr, bp, ETH_ALEN);
> +	memcpy(net->perm_addr, bp, ETH_ALEN);
>  
>  	/* set a nonzero filter to enable data transfers */
>  	memset(u.set, 0, sizeof *u.set);

Ooops...ignore the "1/5" part -- this is the only one...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
