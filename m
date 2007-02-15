From: Martin Langer <martin-langer-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Thu, 15 Feb 2007 17:51:25 +0100
Message-ID: <20070215165125.GA3328@tuba>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net> <200702142240.01494.mb@bu3sch.de> <1171552024.5220.4.camel@johannes.berg> <200702151613.20746.mb@bu3sch.de> <1171552753.5220.10.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Joseph Jezak <josejx-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1171552753.5220.10.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 15, 2007 at 04:19:13PM +0100, Johannes Berg wrote:
> On Thu, 2007-02-15 at 16:13 +0100, Michael Buesch wrote:
> > On Thursday 15 February 2007 16:07, Johannes Berg wrote:
> > > On Wed, 2007-02-14 at 22:40 +0100, Michael Buesch wrote:
> > > > On Wednesday 14 February 2007 14:18, Johannes Berg wrote:
> > > > > On Sat, 2007-02-10 at 06:55 +0100, Michael Buesch wrote:
> > > > > 
> > > > > > It's likely that old cards still work with v4 firmware,
> > > > > 
> > > > > No, it's absolutely impossible. Rev 2/4 cores have a totally different
> > > > > instruction set in the microcode.
> > > > 
> > > > Ok, I was not talking about _that_ old cards. ;)
> > > 
> > > Are there cards where they have new microcode instruction set but no v4
> > > firmware?
> > 
> > I don't know. I guessed so. Am I wrong? That would be good :)
> 
> I wouldn't think so since we have rev5 v4 firmware and that should be
> the oldest post-rev4 right?

Yep. We have all kinds of firmware with the new instruction set. It's 
only ucode2 (old instruction set) that's missing. But the later ucode4 
which also uses the old instruction set is available in v4.
OTOH, ucode13 isn't available in v3. We can't offer one firmware version 
for all card revisions. Both are limited to a specific range of 
revisions.

v3	rev2...rev12
v4	rev4...<=rev13


Martin
