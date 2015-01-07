From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] wireless extensions should default to Y
Date: Wed, 7 Jan 2015 12:03:23 +0100
Message-ID: <20150107110323.GB7368@amd>
References: <20150107101903.GA6563@amd>
 <1420627315.3407.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jikos@suse.cz, kernel list <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1420627315.3407.2.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed 2015-01-07 11:41:55, Johannes Berg wrote:
> On Wed, 2015-01-07 at 11:19 +0100, Pavel Machek wrote:
> > Do we need following patch on top of
> > 24a0aa212ee2dbe44360288684478d76a8e20a0a revert?
> > 
> > I updated kernel today, and (probably because extensions were not
> > selectable before), the default choice was "N", which is wrong:
> > oldconfig should result in compatible choices being made, for example
> > to help bisect.
> 
> I don't believe we need this. It has been defaulting to N for a long
> time, it's just that it got thrown out of your config due to building
> inbetween the patch and its revert. Had you built only before and after
> that wouldn't be an issue.

Well, I clearly hit the issue. If someone had _not_ build in between,
the "default y" does not change anything for him, as he will not be
asked thequestion. If someone starts config from scratch, Y is the
safe answer.

> If we default to Y now we send the wrong signal. If you really need to
> bisect something wext related you have far bigger issues I'd think, the
> code hasn't changed *forever*.

I am woried about bisecting something unrelated, and then wext coming
and breaking the bisect. But you are right that it will break the
bisect, anyway...

                                                                        Pavel
									
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
