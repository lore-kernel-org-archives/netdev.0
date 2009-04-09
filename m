From: Pete Zaitcev <zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: usb_mon oops Re: tcpdump crashes 2.6.29.1 (and 2.6.29-rc5)
Date: Wed, 8 Apr 2009 23:23:44 -0600
Message-ID: <20090408232344.afed8103.zaitcev@redhat.com>
References: <18906.49779.243047.207639@stoffel.org>
	<20090407120022.GA6519@ff.dom.local>
	<18907.28788.965069.573489@stoffel.org>
	<20090407130403.e0061a8d.zaitcev@redhat.com>
	<18908.42166.404232.721757@stoffel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <18908.42166.404232.721757-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 8 Apr 2009 09:20:54 -0400, "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org> wrote:

> Well I think that usbmon is probably at fault here for trusting
> drivers too much and not doing any sanity checking. []

By the way, please send me a full dmesg from the affected system
and kernel. Any post-boot dmesg will do: I only want to see if
IOMMU is active, where the aperture is, and if 0x20a15cc0 is a
valid physical address.

-- Pete
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
