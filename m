From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Tue, 3 Nov 2009 20:59:23 +0100
Message-ID: <200911032059.23409.bzolnier@gmail.com>
References: <1256886023.3555.5.camel@johannes.local> <4AEF1894.2010809@xenotime.net> <200911021943.12069.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>,
	Luis Correia <luis.f.correia@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ingo Molnar <mingo@elte.hu>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755332AbZKCUBy@vger.kernel.org>
In-Reply-To: <200911021943.12069.IvDoorn@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 02 November 2009 19:43:10 Ivo van Doorn wrote:
> Well and then another rt2x00 developer discovered this nice little
> fight about rt2x00 on the mailinglists...
> 
> First for the record, because at the start people where talking about the
> maintainership of rt2x00, one thing needs to be straight:
> 
> As mentioned in the MAINTAINERS file, the rt2x00 project is listed as maintainer
> for the rt2x00 drivers. The rt2x00 drivers include _all_ drivers in the
> drivers/net/wireless/rt2x00 folder.
> 
> At this time I am hold the position within the rt2x00 team which is making the
> decisions about the rt2x00 code and design.

rt2x00 doesn't "own" Linux Ralink support, ditto for rt2800 drivers.

This is not how things work here, sorry.

> I am also the one that is (N)Acks the patches from others when they are send
> to the rt2x00-users or linux-wireless mailinglist.

If you are not willing to stand behind your own patches, how do you expect
others to trust your judgment?

> As for my behavior in discussions:
> 
> I am doing my best to listen to all complains regarding the rt2x00 code and design and
> improve it if the complainer has a valid point. However, obviously I can disagree with
> the complainer and in that case I will explain to that person _why_ I disagree. It is up
> to the complainer to convince me that he is right, agree with my response, or whine.
> 
> Now as for more specific responses:
> 
> On Thursday 29 October 2009, Bartlomiej Zolnierkiewicz wrote:
> > rt2800 drivers have their maintainers and I would like to know what they
> > are doing besides complaining about users and staging tree..
> 
> Working for Avanade, Zarafa and as freelancer for Linux Magazine.
> But I guess you mean rt2x00 specific work?
> Well that list consists of:
>  - Listening to people complain
>  - Responding to those people, because otherwise they complain that they are being ignored.
>  - Following bug reports, and request testing or additional information if required
>  - Bugfixing
>  - Reviewing patches from contributors
>  - Applying patches from contributors
>  - Discussing improvements over patches from contributors
> 
> Well nothing of this list should be new to you, but apparently you needed some confirmation.

I meant rt2800 support specifically, sorry if this was not clear.

The work on rt2800 drivers was started in the beginning of 2008 and after
few months you were already behind deadlines that you had set yourself:

	http://markmail.org/message/a753dws6tqytb3a4

During almost two years rt2x00 project didn't manage to produce working
support for rt2800..  in the meantime the world has moved on and we have
another chipset generation (rt30x0) to worry about, and also rt33xx one
on the horizon..

> On Thursday 29 October 2009, Johannes Berg wrote:
> > On Thu, 2009-10-29 at 07:20 -0700, David Miller wrote:
> > 
> > > In case you're concerned, I actually agree with John and others
> > > on this issue, and disagree with your position.
> > 
> > In this particular case, I think it makes more sense to duplicate the
> > code _especially_ because it's not working yet. That frees people
> > hacking on it of having to worry about breaking other devices.
> 
> Thank you Johannes, that is exactly what I was trying to tell Bartlomiej
> in the previous discussion.

Nope, it just adds needles development/maintenance burden since it will
make people lose fixes already applied to the working code, please see my
other mail.

> On Wednesday 28 October 2009, Bartlomiej Zolnierkiewicz wrote:
> > I find it rather disappointing that all my review comments regarding
> > rt2800pci support were just completely ignored and then the initial
> > patch was merged just as it was..
> 
> Your code review comments were commented upon with my reasons
> why this code duplication exists. I even admitted that when the time is
> ready I will remove the code duplication.

The right time was two years ago when you were starting working on those
drivers.  IOW It shouldn't have happened in the first place.

I also have serious questions about transparency of the process and cannot
understand why it takes so long for the code to be pushed upstream.

commit 1761631 -- obvious bugfix and I'm pretty sure I've seen it in rt2x00
tree back in September (you're re-basing rt2x00 tree at random moments so it
is impossible to track the status of patches that you are handling).

rt2800pci patch itself has been getting dust in your tree since at least
April (it hasn't received any bigger updates since then)..

> On Thursday 29 October 2009, Bartlomiej Zolnierkiewicz wrote:
> > Quite the contrary, I'm pretty confident that addressing my review concerns
> > would result in better RT28x00 / RT30x0 support in the very near future.
> 
> The review concerns regarding the duplicate code would only reduce the
> amount of code. It would not magically fix bugs (at least the chance of that
> would be quite small).

Please see my other mail.

> So far rt2800usb performs better then rt2800pci, and the difference gets
> only bigger when I use the exact same register initialization from rt2800usb
> in rt2800pci.
> 
> But Bartjmoiej knows that the register initialization can be exactly the same,
> from his experience with the staging drivers.
> So far hasn't been interested in sharing the knowledge in what must be
> changed in rt2800pci/usb to make them both work with the same register
> initialization.

The knowledge is all in your local copy of linux-next (I don't memorize
things like chipset initialization sequences) and in the review comments
that you have happily dismissed.

-- 
Bartlomiej Zolnierkiewicz
