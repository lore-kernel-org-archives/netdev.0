From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [announce] new rt2800 drivers for Ralink wireless & project
	tree
Date: Wed, 4 Nov 2009 09:37:37 +0100
Message-ID: <20091104083737.GA16978@elte.hu>
References: <200911031951.05235.bzolnier@gmail.com> <200911032200.04516.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>,
	Luis Correia <luis.f.correia@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754303AbZKDIhr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200911032200.04516.IvDoorn@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ivo van Doorn <ivdoorn@gmail.com> wrote:

> >       MAINTAINERS: add rt2800 entry
> 
> I see you decided to take over the maintainership? Doesn't that need 
> the current maintainer to move away, or was this part of the "going 
> over other peoples head" plan?
>
> [...]
>
> These are too much (and too big) patches for me to review at once, 
> I'll look at them later.

Frankly, having read through the recent discussions related to the 
rt2800pci/usb drivers, the subtle (and largely undeserved) group 
violence and abuse you are inflicting on Bart is stomach-turning.

The non-working rt2800pci driver has been pending in your private tree 
for how long, 1.5 _years_?

Look at the diffstat of Bart's driver:

   15 files changed, 4036 insertions(+), 7158 deletions(-)

He reduced your 5.2 KLOC non-working driver into a 1.8 KLOC _working_ 
driver.

And _still_ your complaint about Bart's series is that he updated the 
MAINTAINERS entry and added an entry for rt2800? Heck _sure_ he should 
update it, he is the one doing the hard work of trying to bring it to 
users, trying to clean up a messy driver space, trying to turn crap into 
gold.

The thing is, if you dont have the time or interest to listen to and act 
upon review feedback, be constructive about it and fix (obvious) 
structural problems in your rt2800 code, you should just step aside and 
let Bart maintain what he is apparently more capable of maintaining than 
you are.

What you are doing here is a thinly veiled land-grab: you did a minimal 
token driver for rt2800 that doesnt work, kept it in your private tree 
for _1.5 years_, and the moment someone _else_ came along and did 
something better and more functional in drivers/staging/, you discovered 
your sudden interest for it and moved the crappy driver upstream at 
lightning's speed (it is already in net-next AFAICS, despite negative 
test and review feedback) - ignoring and throwing away all the work that 
Bart has done.

Such behavior wouldnt fly in _any_ other Linux subsystem, but apparently 
there is one set of rules for upstream kernel maintainers and then 
there's another, different set of rules for upstream wireless driver 
maintainers.

Really, you should listen to contrary opinion and _you_ should work 
_hard_ to integrate Bart socially and open up your close circle of 
wireless insiders instead of fighting his 'outsider' contributions every 
which way. We dont care if people are rough, express displeasure and 
show strong opinion about crappy code - but the moment you are 
_excluding_ capable people and playing petty office politics (like you 
are very clearly doing it with Bart here) everyone loses.

Guys, show some minimal amount of honesty, openness and critical 
thinking please ...

	Ingo
