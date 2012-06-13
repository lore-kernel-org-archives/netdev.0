From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 4/7] usbnet: remove EVENT_DEV_OPEN flag
Date: Wed, 13 Jun 2012 12:47:18 +0800
Message-ID: <CACVXFVOjPxK3X5RF7DVJsTj3g3MyKg_49qtaev=ZBthsjBC=OA@mail.gmail.com>
References: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
	<1339463985-9006-5-git-send-email-tom.leiming@gmail.com>
	<201206122014.28408.oliver@neukum.org>
	<CACVXFVPf+Q9i-Ju3GFapiTB2wEWZSBrZ2Gf=WHsLWfWfTnWGpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36755 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732Ab2FMErT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 00:47:19 -0400
In-Reply-To: <CACVXFVPf+Q9i-Ju3GFapiTB2wEWZSBrZ2Gf=WHsLWfWfTnWGpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 13, 2012 at 10:12 AM, Ming Lei <tom.leiming@gmail.com> wrote:
> On Wed, Jun 13, 2012 at 2:14 AM, Oliver Neukum <oliver@neukum.org> wrote:
>> Am Dienstag, 12. Juni 2012, 03:19:42 schrieb Ming Lei:
>>> EVENT_DEV_OPEN is introduced to mark if the interface is opened or
>>> not, but we already have IFF_UP to handle it, so just
>>> remove the flag and use IFF_UP.
>>
>> When is IFF_UP cleared? The flag is tested in usbnet_resume(),
>
> The flag is cleared just after usbnet_stop completes.

Looks we can use the below to replace EVENT_DEV_OPEN:

     (netif_running((dev)->net) && ((dev)->net->flags & IFF_UP))


Thanks,
-- 
Ming Lei
