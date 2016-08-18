From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Thu, 18 Aug 2016 10:03:05 +0200
Message-ID: <1471507385.2157.5.camel@suse.com>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
	 <1468846886.2280.6.camel@suse.com>
	 <CAKfDRXiqDmJadXL4+v7saM431vPAp_8m8F0wvTkkYt-3tNjYyw@mail.gmail.com>
	 <1468849802.2280.11.camel@suse.com>
	 <CAKfDRXjaSz25_b8Na46DJEDvGUsZ-Xye+Rn2+o6Hy0EcuOopkA@mail.gmail.com>
	 <1468851242.2280.14.camel@suse.com> <87y4475t2f.fsf@miraculix.mork.no>
	 <1470664620.3175.18.camel@suse.com> <87oa535d10.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Kristian Evensen <kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87oa535d10.fsf-3F4PFWf5pNjpjLOzFPqGjWGXanvQGlWp@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-08-08 at 20:30 +0200, Bjørn Mork wrote:
> Note that this doesn't include *every* ethernet driver, although there
> certainly are some examples.  There are also a number of serious
> vendors, providing vendor supported drivers for cards with no known
> issues of this kind.
> 
> Where exactly would you like to see this implemented if it isn't going
> into those specific usbnet drivers?

Higher up. I'd prefer a flag to tell the network core that a driver
is unsure about the MAC and the core should deal with it.

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
