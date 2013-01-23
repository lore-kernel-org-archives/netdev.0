From: Andreas Mohr <andi@lisas.de>
Subject: Re: [PATCH net-next 09/15] drivers/net: delete old 8 bit ISA Racal
 ni5010 support.
Date: Wed, 23 Jan 2013 04:27:24 +0100
Message-ID: <20130123032724.GA8769@rhlx01.hs-esslingen.de>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
 <1358819182-28032-10-git-send-email-paul.gortmaker@windriver.com>
 <50FEEF92.3000809@vanbest.org>
 <201301222155.11493.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan-Pascal van Best <janpascal@vanbest.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andreas Mohr <andi@lisas.de>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:52185 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600Ab3AWD1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 22:27:25 -0500
Content-Disposition: inline
In-Reply-To: <201301222155.11493.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jan 22, 2013 at 09:55:11PM +0100, Ondrej Zary wrote:
> I have BNC network too and use it every day. It's mostly used for internet 
> access, with 3c509 and ne2000 cards (one of the machines has currently uptime 
> of 439 days, it runs kernel 3.1). I remember using HP pclan cards too and 
> they worked fine. Too bad they're going away :(
> Also got a nice 3c503 card a year ago or so. The driver worked fine after a 
> simple fix.
> 
> I really hate when a working driver is removed from Linux. New drivers are 
> either missing (alx) or problematic (various rtl8168/8169 variants, some of 
> which work and some don't). So you can't get any new machine and install 
> Linux. You also can't get any old machine and install Linux. If you're lucky 
> and the machine is somehow middle-aged, everything might work...

I have to ack the "any new machine and install Linux" bit, I'm afraid
(or probably in this case it applies to the middle-aged part).
I'm sitting here with an Aspire One probably sold > 3 million times,
and I'm currently still facing at least the following remaining issues:
- USB SDD connection gets broken *at random* on resume,
  which sometimes causes severe data corruption of the root partition
  [device enumeration?]
- fixed-storage reader resets on every resume, causing the existing mount to get
  broken (unless that happens to be XFS-formatted, it's been said)
- charge status indication is unreliable, at least in recent kernels (I
  didn't notice this issue in older ones) - sometimes simply indicates
  PSU where none is, or indicates battery where PSU is [no idea,
  investigation pending]
- rfkill status is problematic (not accurately visible), most likely due
  to issues presenting the correct state due to a stubbed-out rfkill WMI
  interface during netbook BIOS development (thanks but no thanks Acer)
  [I intend to at least brush up on user-side help texts
  to clearly spell out these machine-side support issues]
- webcam had a nice OOPS issue the last time I was using it (~3.5?)
- microphone array probably not very well-supported (probably still
  needs the "select one channel only" workaround to even get initial
  working recording, not to talk about real array support)
- 3.7 seems to show intermediate CPU lockup message (22s) on Intel GPU
  [when having heavily scrolled console output such as my build converter?]
- I'm sure I forgot something

(not mentioning the many issues that I had to help fixing already
initially, e.g. missing fan control [new acerhdf], firmware loader resume fix,
r8169[hah, there it is again] resume issue, ...)

And that's the status on one formerly extremely widely visible machine only :(


As to other network drivers being incomplete, via-rhine currently has
semi-working resume [to be submitted].

As to "might work", booting any of a selection of well-known live CDs on various
machines is quite likely to get you a blank (either rhetorically or for
real, e.g. due to broken graphics support), too (happened to me on
several occasions).

Unfortunately I don't know what's specifically productive about my reply here,
but at least this content suggests that something is not ending up quite
as well as it could be.
Possibly the only suitable answer is to try to brush up on the rate of
things to get fixed, but myself I'm working on several things already,
thus eventually one will get there, but most likely much slower than it
should be.
If there is something to be fixed about process (perhaps better official
central machine testing efforts?), then anything fruitful
should definitely be done.

Andreas Mohr
