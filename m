From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 31/31] CAPI: Officially claim char major 191
Date: Sat, 23 Jan 2010 15:28:28 +0100
Message-ID: <1264256908.3469.58.camel@violet>
References: <cover.1264201406.git.jan.kiszka@web.de>
	 <20100123122430.5a078b4a@lxorguk.ukuu.org.uk>
	 <1264250892.3469.52.camel@violet>  <201001231432.09918.isdn@linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jan Kiszka <jan.kiszka@web.de>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753477Ab0AWO1e@vger.kernel.org>
In-Reply-To: <201001231432.09918.isdn@linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Karsten,

> > > > I found no trace of this mysterious "pcl181" device, neither in-tree
> > > > nor out there in the wild. At the same time, the in-tree CAPI
> > > > middleware is using major 191 for many years now and obviously without
> > > > any conflict. Let's officially claim this major number.
> > >
> > > This is not the way it should have been done but whoever needs spanking
> > > got away with it years ago. Given that this seems the best way forward.
> > >
> > > With LANANA hat on
> > 
> > actually in the days of udev, the capifs is not really needed anymore.
> > The right choice would be to remove it. I haven't been enabling it since
> > years.
> > 
> So far I understand, the pppd capiplugin is the only user of it, so it could 
> be disabled for most users without any problems, as long they are not using
> PPP connections via CAPI.

PPP connection via CAPI works just fine without capifs. You just need
udev to create the device nodes.

> I never understand capifs very well, I think that it can be dropped because of 
> udev, but maybe need some adjustment in user space as well (make sure that
> udev did create the node before  open it).

I am pretty sure that I send a patch for that a long long time ago. I
haven been using CAPI + PPP without capifs.

> I f I remember correctly, here was some proposal  to replace the /dev/capi/ 
> nodes with  devpts, this would remove the complete capi_tty device major
> as well.

Don't remember anything like this. However extending the kernel code
with a CAPI PPP channel type would be better actually.

Regards

Marcel
