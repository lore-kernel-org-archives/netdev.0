From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] CDC_NCM adding support IFF_NOARP for buggy device
Date: Thu, 10 Jan 2013 20:18:35 +0300
Message-ID: <50EEF7EB.4030503@mvista.com>
References: <1357826368-30543-1-git-send-email-cpuwolf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, alexey.orishko@stericsson.com,
	hans.petter.selasky@stericsson.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Wei Shuai <cpuwolf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:60269 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754598Ab3AJQU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 11:20:29 -0500
Received: by mail-la0-f46.google.com with SMTP id fq13so819408lab.19
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 08:20:27 -0800 (PST)
In-Reply-To: <1357826368-30543-1-git-send-email-cpuwolf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/10/2013 04:59 PM, Wei Shuai wrote:

> Signed-off-by: Wei Shuai <cpuwolf@gmail.com>
> ---
>  drivers/net/usb/cdc_ncm.c |   15 +++++++++++++++
>  1 files changed, 15 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 71b6e92..9903f79 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
[...]
> @@ -572,6 +573,10 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
>  	    cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
>  		return -ENODEV;
>  #endif
> +	/*  this buggy device cannot do ARP */
> +	if( (le16_to_cpu(udev->descriptor.idVendor) == 0xAAAA) ) {

   Please run the patch thru scripts/checkpatch.pl and resubmit.

WBR, Sergei
