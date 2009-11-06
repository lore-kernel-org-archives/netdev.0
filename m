From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [announce] new rt2800 drivers for Ralink wireless & project tree
Date: Fri, 6 Nov 2009 18:58:56 +0100
Message-ID: <200911061858.56816.IvDoorn@gmail.com>
References: <200911031951.05235.bzolnier@gmail.com> <200911042251.23506.IvDoorn@gmail.com> <20091106074643.GA5562@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>,
	Luis Correia <luis.f.correia@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f228.google.com ([209.85.219.228]:58910 "EHLO
	mail-ew0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754705AbZKFR64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 12:58:56 -0500
In-Reply-To: <20091106074643.GA5562@ucw.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> > > Look at the diffstat of Bart's driver:
> > > 
> > >    15 files changed, 4036 insertions(+), 7158 deletions(-)
> > > 
> > > He reduced your 5.2 KLOC non-working driver into a 1.8 KLOC _working_ 
> > > driver.
> > 
> > Bullshit, read the mails again.
> 
> This was uncalled for, right?

The way I said it, yes.

But I was frustrated by Ingo with his comment that the driver was magically fixed,
while even Bartlomiej indicated that was not the case. With these comments,
and those were he were his ignorance about the Ralink drivers in the kernel
was apparent, he managed to get me completely upset because I really
got the impression I was talking to a wall or something and overreacted.

> > > And _still_ your complaint about Bart's series is that he updated the 
> > > MAINTAINERS entry and added an entry for rt2800? Heck _sure_ he should 
> > > update it, he is the one doing the hard work of trying to bring it to 
> > > users, trying to clean up a messy driver space, trying to turn crap into 
> > > gold.
> > 
> > So if I want to focus on something different in the kernel, I just send 1 patch,
> > and a second to claim the maintainership of it even though there is an active
> > maintainer available?
> 
> What about listing yourself as a maintainer for a start?

The rt2x00 project is listed as maintainer for everything in the
drivers/net/wireless/rt2x00 folder.

> > > The thing is, if you dont have the time or interest to listen to and act 
> > > upon review feedback, be constructive about it and fix (obvious) 
> > > structural problems in your rt2800 code, you should just step aside and 
> > > let Bart maintain what he is apparently more capable of maintaining than 
> > > you are.
> > >
> > > What you are doing here is a thinly veiled land-grab: you did a minimal 
> > > token driver for rt2800 that doesnt work, kept it in your private tree 
> > > for _1.5 years_, and the moment someone _else_ came along and did 
> > > something better and more functional in drivers/staging/, you discovered 
> > > your sudden interest for it and moved the crappy driver upstream at 
> > > lightning's speed (it is already in net-next AFAICS, despite negative 
> > > test and review feedback) - ignoring and throwing away all the work that 
> > > Bart has done.
> > 
> > Get your facts straight, the bullshit level in your mail is staggering.
> > 
> > You have no fucking clue who wrote the rt2800 driver which is in
> > drivers/staging/,
> 
> Perhaps you should not be a maintainer if you can't behave yourself?

Ok let me explain clearer then:

drivers/net/staging/rt28{6,7}0 was developed by Ralink and I acked
the merged for those drivers after the asurance that it was only merged
to please the users so developers could focus on the rt2x00 version of
the driver.

Anyway, I'll do what John requested and go back into my hole since I
have absolutely no desire to continue this flamewar.

Ivo
