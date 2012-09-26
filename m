From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 5/5] smsc95xx: enable power saving mode during system suspend
Date: Wed, 26 Sep 2012 16:23:27 +0200
Message-ID: <87y5jw982o.fsf@nemi.mork.no>
References: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
	<1348663224-30403-6-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43716 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457Ab2IZOXc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 10:23:32 -0400
In-Reply-To: <1348663224-30403-6-git-send-email-steve.glendinning@shawell.net>
	(Steve Glendinning's message of "Wed, 26 Sep 2012 13:40:24 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning <steve.glendinning@shawell.net> writes:

> +static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t=
 message)
> +{
> +	struct usbnet *dev =3D usb_get_intfdata(intf);
> +	int ret;
> +	u32 val;
> +
> +	BUG_ON(!dev);

That's not very user friendly.  Why not just return here?



Bj=C3=B8rn
