From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Fri, 18 Apr 2008 08:51:04 +0200
Message-ID: <200804180851.05289.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com> <200804171632.12972.oliver@neukum.org> <4807C56F.5060804@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4807C56F.5060804-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, 17. April 2008 23:47:27 schrieb Paulius Zaleckas:
> Oliver Neukum wrote:
> > can you test this one as well. The method used to determine whether
> > a device is asleep is racy. This introduces a private test.
> 
> Stupid question :) How to test it? How can I force it to suspend?
> I have never used any suspend on my PC :)

This is runtime power management. It can save energy on any computer.
You compile your kernel with CONFIG_USB_SUSPEND and to see something
in syslog with CONFIG_USB_DEBUG.
Plug in the device, locate its sysfs directory, cd into it and do
echo "auto" >power/level

After a few seconds of idleness the device and the hub it's connected to
(if it's the only device at that hub) should suspend. You'll get a message
about it in the kernel log.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
