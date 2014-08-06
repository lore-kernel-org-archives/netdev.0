From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fix USB network driver config option.
Date: Wed, 06 Aug 2014 16:00:46 -0700 (PDT)
Message-ID: <20140806.160046.771071329736545016.davem@davemloft.net>
References: <20140806223640.GA24673@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linville@tuxdriver.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbaHFXAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 19:00:51 -0400
In-Reply-To: <20140806223640.GA24673@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 7 Aug 2014 00:36:40 +0200

> From: Francois Romieu <romieu@fr.zoreil.com>
> 
> It must be tristate to avoid broken dependencies with kernel built-in
> usb network drivers when usb support is module only.
> 
> When net config option is set, least surprize default should match usb.
> 
> Wireless RNDIS USB driver used to select USB_USBNET. USB_USBNET now
> depends on USB_NET_DRIVERS so the latter should be selected as well.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Ok, applied, thanks.
