From: Paul TBBle Hampson <Paul.Hampson@Pobox.com>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Sun, 12 Nov 2006 12:24:30 +1100
Message-ID: <20061112012430.GA29648@keitarou>
References: <ej09qf$2nv$1@sea.gmane.org> <200611102112.33050.mb@bu3sch.de> <loom.20061111T070237-788@post.gmane.org> <200611111607.05420.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from betty.cbit.net.au ([202.55.154.10]:60827 "EHLO mail.cbit.net.au")
	by vger.kernel.org with ESMTP id S1947388AbWKLBWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Nov 2006 20:22:47 -0500
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200611111607.05420.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 11, 2006 at 04:07:05PM +0100, Michael Buesch wrote:
> Please _don't_ remove CCs.

Sorry, I was sending via the gmane web interface, I guess it doesn't
honour CCs.

This one's via muttng's NNTP support to gmane, so I _think_ it's going
to the right places.

> On Saturday 11 November 2006 07:32, Paul Hampson wrote:
>> Michael Buesch <mb <at> bu3sch.de> writes:

> >> On Thursday 09 November 2006 23:23, Paul Hampson wrote:
> > >> I've been backporting the bcm43xx-d80211 driver to whatever the released
> > >> 2.6 kernel was using the rt2x00 project's d80211 stack (equivalent to
> > >> current wireless-dev but with a workaround for not having a ieee80211_dev
> > >> pointer and still using the _tfm interface instead of the _cypher interface.)

> > >> As of last night's wireless-dev tree bcm43xx, everything seems to be
> > >> operating fine except incoming broadcast traffic is coming in 14 bytes too
> > >> long and scrambled. I presume this means it's not decrypting properly...

> >> It sounds like a bug in the hardware decryption setup.
> >> Are you using TKIP or not?

>> Yes, it's using TKIP. The router docs and the loading of the tkip module
>> when I use the softmac driver agree on this.

> TKIP is still software encryption. Did you try with WPA-AES, for example,
> which is hardware encryption?

The router here only supports TKIP that I can see. There's another
network I'll be on on Monday night which I might be able to throw into
WPA2 mode... In fact, I was there yesterday and couldn't even get a
DHCP IP address, but didn't have the time to diagnose it.

> The problem might be that the card tries to decrypt mcast
> frames in the crypto hardware, although we did not set a key.
> So it uses a random key to decrypt. That obviously results in crap.

Eww, yuck.

-- 
-----------------------------------------------------------
Paul "TBBle" Hampson, B.Sc, LPI, MCSE
On-hiatus Asian Studies student, ANU
The Boss, Bubblesworth Pty Ltd (ABN: 51 095 284 361)
Paul.Hampson@Pobox.Com

Of course Pacman didn't influence us as kids. If it did,
we'd be running around in darkened rooms, popping pills and
listening to repetitive music.
 -- Kristian Wilson, Nintendo, Inc, 1989

License: http://creativecommons.org/licenses/by/2.1/au/
-----------------------------------------------------------
