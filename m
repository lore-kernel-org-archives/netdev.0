From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Resend 1/3] net: cdc-phonet: Staticize usbpn_probe
Date: Wed, 18 Sep 2013 12:21:24 -0400 (EDT)
Message-ID: <20130918.122124.464642242992278820.davem@davemloft.net>
References: <1379475001-24505-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, remi@remlab.net
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627Ab3IRQV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 12:21:26 -0400
In-Reply-To: <1379475001-24505-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Wed, 18 Sep 2013 08:59:59 +0530

> @@ -328,7 +328,8 @@ MODULE_DEVICE_TABLE(usb, usbpn_ids);
>  
>  static struct usb_driver usbpn_driver;
>  
> -int usbpn_probe(struct usb_interface *intf, const struct usb_device_id *id)
> +static int
> +usbpn_probe(struct usb_interface *intf, const struct usb_device_id *id)

Please keep it to one line, it's 82 columns which is fine.
