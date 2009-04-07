From: Pete Zaitcev <zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: usb_mon oops Re: tcpdump crashes 2.6.29.1 (and 2.6.29-rc5)
Date: Tue, 7 Apr 2009 13:04:03 -0600
Message-ID: <20090407130403.e0061a8d.zaitcev@redhat.com>
References: <18906.49779.243047.207639@stoffel.org>
	<20090407120022.GA6519@ff.dom.local>
	<18907.28788.965069.573489@stoffel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <18907.28788.965069.573489-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Apr 2009 11:25:40 -0400, "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org> wrote:

> But I'm surprised that USB_MON would be the cause when it's a
> networking tool which is starting up?  *shrug*

The libpcap supports usbmon. Perhaps it scans something.

The big problem with usbmon is, it has to trust what drivers
stuff into URBs. Bet it's your uvcvideo. A rough driver, that.

-- Pete
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
