From: "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>
Subject: Re: usb_mon oops Re: tcpdump crashes 2.6.29.1 (and 2.6.29-rc5)
Date: Thu, 9 Apr 2009 23:01:09 -0400
Message-ID: <18910.46709.707557.135033@stoffel.org>
References: <18906.49779.243047.207639@stoffel.org>
	<20090407120022.GA6519@ff.dom.local>
	<18907.28788.965069.573489@stoffel.org>
	<20090407130403.e0061a8d.zaitcev@redhat.com>
	<18908.42166.404232.721757@stoffel.org>
	<20090408232344.afed8103.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>,
	Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pete Zaitcev <zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090408232344.afed8103.zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Ok, I've confirmed that it's usbmon under 2.6.29.1 on x86_64 which causes
complete system lockups when doing 'tcpdump host ##.##.##.##'.  I
compiled usbmon as a module, started a tcpdump and couldn't get a
crash. 

Loaded the module with tcpdump still going, no problems.  Stop and
restart tcpdump, bang!  Instant hang.  I'm now building 2.6.28 to see
if that works properly or not.  I suspect I might have to go back
farther, but I'm not sure.

Any suggestions of a known good state I should start bisection from?

Thanks,
John
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
