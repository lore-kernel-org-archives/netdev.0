From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] smsc75xx: support PHY wakeup source
Date: Tue, 27 Nov 2012 07:56:44 -0800
Message-ID: <1354031804.2116.8.camel@joe-AO722>
References: <1354026482-10443-1-git-send-email-steve.glendinning@shawell.net>
	 <1354026482-10443-3-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:53558 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754981Ab2K0P4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 10:56:44 -0500
In-Reply-To: <1354026482-10443-3-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 14:28 +0000, Steve Glendinning wrote:
> This patch enables LAN7500 family devices to wake from suspend
> on either link up or link down events.
[]
> diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
[]
> +static int smsc75xx_enter_suspend1(struct usbnet *dev)
> +{
> +	u32 val;
> +	int ret;
> +
> +	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
> +	check_warn_return(ret, "Error reading PMT_CTL");

Hi Steve, can you please add newlines to these new
check_warn_<foo> messages and the netdev_<level> ones too?
It helps avoid message interleaving.

> +		if (!link_up) {
> +			struct mii_if_info *mii = &dev->mii;
> +			netdev_info(dev->net, "entering SUSPEND1 mode");

etc..
