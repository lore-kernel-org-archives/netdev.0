From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Tue, 3 Nov 2009 21:32:30 +0100
Message-ID: <200911032132.31533.IvDoorn@gmail.com>
References: <1256886023.3555.5.camel@johannes.local> <200911021943.12069.IvDoorn@gmail.com> <200911032059.23409.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
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
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:38986 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbZKCUcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 15:32:31 -0500
In-Reply-To: <200911032059.23409.bzolnier@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 03 November 2009, Bartlomiej Zolnierkiewicz wrote:
> On Monday 02 November 2009 19:43:10 Ivo van Doorn wrote:
> > Well and then another rt2x00 developer discovered this nice little
> > fight about rt2x00 on the mailinglists...
> > 
> > First for the record, because at the start people where talking about the
> > maintainership of rt2x00, one thing needs to be straight:
> > 
> > As mentioned in the MAINTAINERS file, the rt2x00 project is listed as maintainer
> > for the rt2x00 drivers. The rt2x00 drivers include _all_ drivers in the
> > drivers/net/wireless/rt2x00 folder.
> > 
> > At this time I am hold the position within the rt2x00 team which is making the
> > decisions about the rt2x00 code and design.
> 
> rt2x00 doesn't "own" Linux Ralink support, ditto for rt2800 drivers.

You really have problems reading mails, haven't you? Or at least you
only want to read what you want to read...

Please READ the paragraph again.
 
I will highlight the thing again:
"about the rt2x00 code and design"

I am not talking about Ralink support I am talking about RT2X00 support.

If you feel that the maintainer of a particular driver has no say about the driver
he wrote himself, then I am not seeing the point of having maintainers. We can
then all just randomly hack in all drivers without any form of structure.

> > I am also the one that is (N)Acks the patches from others when they are send
> > to the rt2x00-users or linux-wireless mailinglist.
> 
> If you are not willing to stand behind your own patches, how do you expect
> others to trust your judgment?

Ehm, please explain? I am sending patches upstream, but apparently I don't stand behind them?
Then why the f*** am I sending them?

> > As for my behavior in discussions:
> > 
> > I am doing my best to listen to all complains regarding the rt2x00 code and design and
> > improve it if the complainer has a valid point. However, obviously I can disagree with
> > the complainer and in that case I will explain to that person _why_ I disagree. It is up
> > to the complainer to convince me that he is right, agree with my response, or whine.
> > 
> > Now as for more specific responses:
> > 
> > On Thursday 29 October 2009, Bartlomiej Zolnierkiewicz wrote:
> > > rt2800 drivers have their maintainers and I would like to know what they
> > > are doing besides complaining about users and staging tree..
> > 
> > Working for Avanade, Zarafa and as freelancer for Linux Magazine.
> > But I guess you mean rt2x00 specific work?
> > Well that list consists of:
> >  - Listening to people complain
> >  - Responding to those people, because otherwise they complain that they are being ignored.
> >  - Following bug reports, and request testing or additional information if required
> >  - Bugfixing
> >  - Reviewing patches from contributors
> >  - Applying patches from contributors
> >  - Discussing improvements over patches from contributors
> > 
> > Well nothing of this list should be new to you, but apparently you needed some confirmation.
> 
> I meant rt2800 support specifically, sorry if this was not clear.
> 
> The work on rt2800 drivers was started in the beginning of 2008 and after
> few months you were already behind deadlines that you had set yourself:
> 
> 	http://markmail.org/message/a753dws6tqytb3a4
> 
> During almost two years rt2x00 project didn't manage to produce working
> support for rt2800..  in the meantime the world has moved on and we have
> another chipset generation (rt30x0) to worry about, and also rt33xx one
> on the horizon..

And thank you for your valuable effort in assisting in the driver development
during those 2 years. I am really happy about people looking from the sideline
and complaining things are not moving as fast as they would like it.
If you cared about the slow progress, then you had the past 2 years to help out,
but apparently that is too much to ask. Unfortunately a lot of people think like
you, which means that during those 2 years dozens of people have complained
about the lack of progress without any of them helping out (and I am not talking
about users only, I am also talking about people who have programming skills).

If you look at the Signed-off list of the rt2800pci/usb patches you will see that
only a handfull of people actually helped.

> > On Thursday 29 October 2009, Johannes Berg wrote:
> > > On Thu, 2009-10-29 at 07:20 -0700, David Miller wrote:
> > > 
> > > > In case you're concerned, I actually agree with John and others
> > > > on this issue, and disagree with your position.
> > > 
> > > In this particular case, I think it makes more sense to duplicate the
> > > code _especially_ because it's not working yet. That frees people
> > > hacking on it of having to worry about breaking other devices.t initialization sequences) and in the review 
> > 
> > Thank you Johannes, that is exactly what I was trying to tell Bartlomiej
> > in the previous discussion.
> 
> Nope, it just adds needles development/maintenance burden since it will
> make people lose fixes already applied to the working code, please see my
> other mail.

As mentioned in my mail, there were differences in the drivers during development,
and I had a working rt2800usb driver as base. But with the same settings the rt2800pci
couldn't get to work.

With the merged drivers you would constantly need to check if it works for rt2800pci,
but also if you haven't broken rt2800usb in the meantime. This way rt2800usb was
able to be merged months before rt2800pci because there was no common code.

Once both drivers are solid working, then there are no problems with merging them,
I wonder how many times I have to repeat that...

> > On Wednesday 28 October 2009, Bartlomiej Zolnierkiewicz wrote:
> > > I find it rather disappointing that all my review comments regarding
> > > rt2800pci support were just completely ignored and then the initial
> > > patch was merged just as it was..
> > 
> > Your code review comments were commented upon with my reasons
> > why this code duplication exists. I even admitted that when the time is
> > ready I will remove the code duplication.
> 
> The right time was two years ago when you were starting working on those
> drivers.  IOW It shouldn't have happened in the first place.

Please see my other mail, please read my above comment, and thank you again
for participating in the rt2800 development of those 2 years.

> I also have serious questions about transparency of the process and cannot
> understand why it takes so long for the code to be pushed upstream.

So you start looking now, and complain you can't see the process of the last 2 years?
There have been dozens of status reports regarding rt2800, and the number of responses
in general have always been limited.

But now I reread that last sentence, you are complaining that rt2800pci wasn't pushed
upstream earlier? While this whole discussion is about that merging rt2800pci was a bad
idea?

> commit 1761631 -- obvious bugfix and I'm pretty sure I've seen it in rt2x00
> tree back in September (you're re-basing rt2x00 tree at random moments so it
> is impossible to track the status of patches that you are handling).

I'm missing the point here.

> rt2800pci patch itself has been getting dust in your tree since at least
> April (it hasn't received any bigger updates since then)..

And how many times do I have to repeat the reason?
I think that after dozens of mails, the message should have been clear, especially
to somebody who apparently has been monitoring and worrying about the development
process for the last 2 years....

> > On Thursday 29 October 2009, Bartlomiej Zolnierkiewicz wrote:
> > > Quite the contrary, I'm pretty confident that addressing my review concerns
> > > would result in better RT28x00 / RT30x0 support in the very near future.
> > 
> > The review concerns regarding the duplicate code would only reduce the
> > amount of code. It would not magically fix bugs (at least the chance of that
> > would be quite small).
> 
> Please see my other mail.

And did your patches make rt2800pci work better?
Does rt2800usb suddenly work for 11n networks?

> > So far rt2800usb performs better then rt2800pci, and the difference gets
> > only bigger when I use the exact same register initialization from rt2800usb
> > in rt2800pci.
> > 
> > But Bartjmoiej knows that the register initialization can be exactly the same,
> > from his experience with the staging drivers.
> > So far hasn't been interested in sharing the knowledge in what must be
> > changed in rt2800pci/usb to make them both work with the same register
> > initialization.
> 
> The knowledge is all in your local copy of linux-next (I don't memorize
> things like chipset initialization sequences) and in the review comments
> that you have happily dismissed.

Your review comments were regarding _moving_ code to a generic stack
for rt2800pci and rt2800usb while I already indicated that would not improve
the status of rt2800pci (instead it would make it worse, since I already tested
if those settings would work). But apparently merging the code is better then
fixing the code.

Ivo
