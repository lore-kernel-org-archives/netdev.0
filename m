From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: btusb suspend/resume bug...
Date: Wed, 17 Sep 2008 18:17:49 +0200
Message-ID: <1221668269.6782.8.camel@californication>
References: <20080916.155123.181085856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080916.155123.181085856.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> Marcel, others, please bring some kind of closure to this
> regression list entry:
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11442
> Subject		: btusb hibernation/suspend breakage in current -git
> Submitter	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
> Date		: 2008-08-25 11:37 (19 days old)
> References	: http://marc.info/?l=linux-bluetooth&m=121966402012074&w=4
> Handled-By	: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
> Patch		: http://marc.info/?l=linux-bluetooth&m=121967226027323&w=4
> 
> There is a patch, it is tested, so the only course of action at
> this point is to merge the fix or declare that this really isn't
> a regression.
> 
> My impression is the later, because the driver btusb is replacing
> doesn't handle suspend/resume either.  Isn't that right?

the original patch that I had was expecting changes in the USB subsystem
that I deemed to much at this point. However Oliver got a patch that
would make it work without the USB changes. I am still testing it.

Let me see if I get some free minutes during the PlumbersConf to get
this fully tested.

Actually hci_usb is handling suspend/resume to some degree. So we could
count this as regression.

Regards

Marcel
