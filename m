From: Karsten Keil <isdn@linux-pingi.de>
Subject: Re: [PATCH 31/31] CAPI: Officially claim char major 191
Date: Sat, 23 Jan 2010 14:32:09 +0100
Message-ID: <201001231432.09918.isdn@linux-pingi.de>
References: <cover.1264201406.git.jan.kiszka@web.de> <20100123122430.5a078b4a@lxorguk.ukuu.org.uk> <1264250892.3469.52.camel@violet>
Reply-To: isdn@linux-pingi.de
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-3"
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jan Kiszka <jan.kiszka@web.de>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:58055 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab0AWNcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 08:32:22 -0500
In-Reply-To: <1264250892.3469.52.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Samstag, 23. Januar 2010 13:48:12 Marcel Holtmann wrote:
> Hi Alan,
> 
> > > I found no trace of this mysterious "pcl181" device, neither in-tree
> > > nor out there in the wild. At the same time, the in-tree CAPI
> > > middleware is using major 191 for many years now and obviously without
> > > any conflict. Let's officially claim this major number.
> >
> > This is not the way it should have been done but whoever needs spanking
> > got away with it years ago. Given that this seems the best way forward.
> >
> > With LANANA hat on
> 
> actually in the days of udev, the capifs is not really needed anymore.
> The right choice would be to remove it. I haven't been enabling it since
> years.
> 
So far I understand, the pppd capiplugin is the only user of it, so it could 
be disabled for most users without any problems, as long they are not using
PPP connections via CAPI.

I never understand capifs very well, I think that it can be dropped because of 
udev, but maybe need some adjustment in user space as well (make sure that
udev did create the node before  open it).

I f I remember correctly, here was some proposal  to replace the /dev/capi/ 
nodes with  devpts, this would remove the complete capi_tty device major
as well.

Karsten
