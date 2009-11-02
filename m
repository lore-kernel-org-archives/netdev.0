From: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Mon, 2 Nov 2009 19:43:10 +0100
Message-ID: <200911021943.12069.IvDoorn@gmail.com>
References: <1256886023.3555.5.camel@johannes.local> <efe7343f0911020932l21a570c8u9478568329d38e2c@mail.gmail.com> <4AEF1894.2010809@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>,
	Luis Correia <luis.f.correia-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AEF1894.2010809-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Well and then another rt2x00 developer discovered this nice little
fight about rt2x00 on the mailinglists...

First for the record, because at the start people where talking about the
maintainership of rt2x00, one thing needs to be straight:

As mentioned in the MAINTAINERS file, the rt2x00 project is listed as maintainer
for the rt2x00 drivers. The rt2x00 drivers include _all_ drivers in the
drivers/net/wireless/rt2x00 folder.

At this time I am hold the position within the rt2x00 team which is making the
decisions about the rt2x00 code and design.
I am also the one that is (N)Acks the patches from others when they are send
to the rt2x00-users or linux-wireless mailinglist.

As for my behavior in discussions:

I am doing my best to listen to all complains regarding the rt2x00 code and design and
improve it if the complainer has a valid point. However, obviously I can disagree with
the complainer and in that case I will explain to that person _why_ I disagree. It is up
to the complainer to convince me that he is right, agree with my response, or whine.

Now as for more specific responses:

On Thursday 29 October 2009, Bartlomiej Zolnierkiewicz wrote:
> rt2800 drivers have their maintainers and I would like to know what they
> are doing besides complaining about users and staging tree..

Working for Avanade, Zarafa and as freelancer for Linux Magazine.
But I guess you mean rt2x00 specific work?
Well that list consists of:
 - Listening to people complain
 - Responding to those people, because otherwise they complain that they are being ignored.
 - Following bug reports, and request testing or additional information if required
 - Bugfixing
 - Reviewing patches from contributors
 - Applying patches from contributors
 - Discussing improvements over patches from contributors

Well nothing of this list should be new to you, but apparently you needed some confirmation.

On Thursday 29 October 2009, Johannes Berg wrote:
> On Thu, 2009-10-29 at 07:20 -0700, David Miller wrote:
> 
> > In case you're concerned, I actually agree with John and others
> > on this issue, and disagree with your position.
> 
> In this particular case, I think it makes more sense to duplicate the
> code _especially_ because it's not working yet. That frees people
> hacking on it of having to worry about breaking other devices.

Thank you Johannes, that is exactly what I was trying to tell Bartlomiej
in the previous discussion.

On Wednesday 28 October 2009, Bartlomiej Zolnierkiewicz wrote:
> I find it rather disappointing that all my review comments regarding
> rt2800pci support were just completely ignored and then the initial
> patch was merged just as it was..

Your code review comments were commented upon with my reasons
why this code duplication exists. I even admitted that when the time is
ready I will remove the code duplication.

On Thursday 29 October 2009, Bartlomiej Zolnierkiewicz wrote:
> Quite the contrary, I'm pretty confident that addressing my review concerns
> would result in better RT28x00 / RT30x0 support in the very near future.

The review concerns regarding the duplicate code would only reduce the
amount of code. It would not magically fix bugs (at least the chance of that
would be quite small).

So far rt2800usb performs better then rt2800pci, and the difference gets
only bigger when I use the exact same register initialization from rt2800usb
in rt2800pci.

But Bartjmoiej knows that the register initialization can be exactly the same,
from his experience with the staging drivers.
So far hasn't been interested in sharing the knowledge in what must be
changed in rt2800pci/usb to make them both work with the same register
initialization.

On Monday 02 November 2009, Randy Dunlap wrote:
> Luis Correia wrote:
> > [huge snip]
> > I've searched on my GMail archives and the only patch Bart has
> > provided so far for the rt2x00 project is this:
> > 
> > [PATCH] MAINTAINERS: rt2x00 list is moderated
> > 
> > Which, while technically correct, adds nothing to the project.
> 
> whatever.  That patch still needs to be applied.

And I haven't seen anybody stating the opposite...

Ivo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
