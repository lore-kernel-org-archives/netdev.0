From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] wireless extensions should default to Y
Date: Wed, 07 Jan 2015 12:06:42 +0100
Message-ID: <1420628802.3407.4.camel@sipsolutions.net>
References: <20150107101903.GA6563@amd>
	 <1420627315.3407.2.camel@sipsolutions.net> <20150107110323.GB7368@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jikos-AlSwsSmVLrQ@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150107110323.GB7368@amd>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-01-07 at 12:03 +0100, Pavel Machek wrote:
> On Wed 2015-01-07 11:41:55, Johannes Berg wrote:
> > On Wed, 2015-01-07 at 11:19 +0100, Pavel Machek wrote:
> > > Do we need following patch on top of
> > > 24a0aa212ee2dbe44360288684478d76a8e20a0a revert?
> > > 
> > > I updated kernel today, and (probably because extensions were not
> > > selectable before), the default choice was "N", which is wrong:
> > > oldconfig should result in compatible choices being made, for example
> > > to help bisect.
> > 
> > I don't believe we need this. It has been defaulting to N for a long
> > time, it's just that it got thrown out of your config due to building
> > inbetween the patch and its revert. Had you built only before and after
> > that wouldn't be an issue.
> 
> Well, I clearly hit the issue. If someone had _not_ build in between,
> the "default y" does not change anything for him, as he will not be
> asked thequestion. If someone starts config from scratch, Y is the
> safe answer.

We've long stated that if really starting from scratch it's the wrong
thing to do and had a default N, so I don't really know why we'd revert
that only to make a short period of bisect slightly happier?

I really don't want to merge this patch and encourage more people to
build with wext enabled.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
