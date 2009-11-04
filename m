From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [announce] new rt2800 drivers for Ralink wireless & project tree
Date: Wed, 4 Nov 2009 22:51:22 +0100
Message-ID: <200911042251.23506.IvDoorn@gmail.com>
References: <200911031951.05235.bzolnier@gmail.com> <200911032200.04516.IvDoorn@gmail.com> <20091104083737.GA16978@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>,
	Luis Correia <luis.f.correia@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:45714 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932970AbZKDVvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:51:21 -0500
In-Reply-To: <20091104083737.GA16978@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 04 November 2009, Ingo Molnar wrote:
> 
> * Ivo van Doorn <ivdoorn@gmail.com> wrote:
> 
> > >       MAINTAINERS: add rt2800 entry
> > 
> > I see you decided to take over the maintainership? Doesn't that need 
> > the current maintainer to move away, or was this part of the "going 
> > over other peoples head" plan?
> >
> > [...]
> >
> > These are too much (and too big) patches for me to review at once, 
> > I'll look at them later.
> 
> Frankly, having read through the recent discussions related to the 
> rt2800pci/usb drivers, the subtle (and largely undeserved) group 
> violence and abuse you are inflicting on Bart is stomach-turning.
> 
> The non-working rt2800pci driver has been pending in your private tree 
> for how long, 1.5 _years_?

Something like that.

> Look at the diffstat of Bart's driver:
> 
>    15 files changed, 4036 insertions(+), 7158 deletions(-)
> 
> He reduced your 5.2 KLOC non-working driver into a 1.8 KLOC _working_ 
> driver.

Bullshit, read the mails again.
I have acked a portion of fixes because those were small and obviously
correct. There are some minor bugfixes in them but none of them would
magically make the card work for everybody. So the number of lines is
decreased but the status of the driver is the same.

Some people actually require sleep during the night, perhaps that you don't need
that and can hence review 41 patches which changes thousands of lines on the
same day the patches were submitted.

> And _still_ your complaint about Bart's series is that he updated the 
> MAINTAINERS entry and added an entry for rt2800? Heck _sure_ he should 
> update it, he is the one doing the hard work of trying to bring it to 
> users, trying to clean up a messy driver space, trying to turn crap into 
> gold.

So if I want to focus on something different in the kernel, I just send 1 patch,
and a second to claim the maintainership of it even though there is an active
maintainer available?

> The thing is, if you dont have the time or interest to listen to and act 
> upon review feedback, be constructive about it and fix (obvious) 
> structural problems in your rt2800 code, you should just step aside and 
> let Bart maintain what he is apparently more capable of maintaining than 
> you are.
>
> What you are doing here is a thinly veiled land-grab: you did a minimal 
> token driver for rt2800 that doesnt work, kept it in your private tree 
> for _1.5 years_, and the moment someone _else_ came along and did 
> something better and more functional in drivers/staging/, you discovered 
> your sudden interest for it and moved the crappy driver upstream at 
> lightning's speed (it is already in net-next AFAICS, despite negative 
> test and review feedback) - ignoring and throwing away all the work that 
> Bart has done.

Get your facts straight, the bullshit level in your mail is staggering.

You have no fucking clue who wrote the rt2800 driver which is in drivers/staging/,
you have no clue why it was added, and you don't even know what the intention
was for that driver from day 1 (which was clearly communicated!)

You even are missing the point _why_ the rt2x00 driver was 1.5 years in development,
but I'll highlight that part for you:

	Because a lot of people prefer looking from the sideline, contributing _nothing_
	and then after a year complain that the development is going too slowly and they
	could have done better. Apparently that is the style you prefer, but that is most
	definately _not_ how I think Open Source should work.

As for "throwing away that work" I ACKED 10 of his patches, and said I would review
the rest later! But like I said, apparently it is a bad habit for people to sleep during
the night.

> Such behavior wouldnt fly in _any_ other Linux subsystem, but apparently 
> there is one set of rules for upstream kernel maintainers and then 
> there's another, different set of rules for upstream wireless driver 
> maintainers.

So non-wireless maintainers don't need to review patches before giving their Ack?
Well that makes the Acked-by and Signed-off rules completely meaningless,
I wonder why everybody is demanding it before patches are merged...

Ivo
