From: David Brownell <david-b@pacbell.net>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function `usbnet_set_settings':
Date: Wed, 7 Nov 2007 14:15:28 -0800
Message-ID: <200711071415.29234.david-b@pacbell.net>
References: <200711012024.57412.toralf.foerster@gmx.de> <200711011632.18333.david-b@pacbell.net> <20071107.002007.00442348.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: randy.dunlap@oracle.com, toralf.foerster@gmx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	greg@kroah.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.sbc.mail.sp1.yahoo.com ([69.147.64.93]:31010 "HELO
	smtp120.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754657AbXKGWPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 17:15:32 -0500
In-Reply-To: <20071107.002007.00442348.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 November 2007, David Miller wrote:
> David, I hate to say this and point you out like this, but you are a
> real cancer for bug fixes to USB things in the kernel,

You didn't hate it enough to find a way to deal with your issue
that doesn't involve namecalling or other flamage, I'll note.

I know, I know ... you wouldn't want anyone to get the mistaken
impression that LKML is one of those easy-to-get-along-on mailing
lists. =A0Namecalling helps prevent anyone from ever thinking that!


> If I had a nickel for every patch from someone else you grinded into
> the ground and stalled I'd truly be a millionare.

Hyperbole helps too...

Twenty million patches, surely from some large fraction of a
million kernel patch submitters ... what a crazy dream!
(An enviable one, maybe; but way below the last statistics
on the subject which I read.)

As for "grind into the ground and stall" ... clearly that's
not how I'd describe things.


> You absolutely stifle development progress. =A0I thought my OHCI
> deadlock patch was an isolated case (and nothing is still applied,
> which is just awesome, my original patch was posted more than a month
> ago),

I'm not sure why the patch I signed off on didn't merge either;
that was specificially related to the OHCI part of that problem.

Hmm, digging through my mail I see several other patches doing
the same thing were also floating around.  None of them had any
improvement over what I had signed off on.  Maybe there was just
too much confusion for Greg to want to merge the one which I'd
already signed off on...


It hasn't been removed from my merge queue, since it's not yet
shown up from kernel.org ... which means that it'd be one of
the patches to be resubmitted before we get much deeper into
this particular RC series.  In fact, I just resent it (with a
few minor tweaks, essentially comment updates).


Of course, *YOU* are the roadblock on the more generic side of
that problem.  I don't recall hearing back from you about the
minor/obvious update to the HUB+EHCI patch adding a msleep()
to bypass the hardware race you reported.

That is, other than your refusal to even try letting the three
or more clock domains finish synchronizing, before releasing
that lock and then starting something that relied on that synch
having finished...


>=A0=A0=A0=A0=A0=A0=A0but you're doing the same exact thing to Adrian h=
ere too.

Hmm, and there I was prepared to sign off on Adrian's last patch.
True, I hadn't yet done so.  But there were several workable fixes
in hand, plus a trivial workaround ... I just didn't make time to
try that one out over the weekend.

I'm glad you grabbed the patch I would have signed off on, if I'd
had time to verify it.


> You want to see things fixed your way. =A0But you can get away with t=
he
> if, and only if, you can spend every day working on your own version
> of fixes when you don't like the submitters version.

You know, that's hardly a standard kernel-wide policy for how
maintainers work ... except maybe ones in "supported" areas,
and not always even then.

Though I certainly know why it could seem attactive to want that
treatment for patches you submit. I know many of us would just love
to get that level of response/support for everything we submit.
I don't always get it; in some areas, it *never* happens.

In fact, it's pretty routine to have patches wait for a while
before they get merged, or even sometimes reviewed ... where
"a while" will sometimes cover many (annoying) months.


Also, some maintainers demand many iterations of patches, without
doing *any* fixup themselves. =A0It's as if ... hmm ... maybe there
were only so many hours per day going into that such stuff?  Or as
if people had different priorities? =A0Bizarre notions, I know!!


>=A0=A0=A0=A0=A0=A0=A0But unlike me
> you don't have that luxury so you have to give patch submitters a
> larger level of freedom and, plainly, just "let go".

Same goes for maintainers too, you know.  If you're still
wondering about a patch, a private "ping" is common practice;
far more so than public vilification.

In fact, it's best if you never use a public vilification step.
Certainly not until after conventional measures ("ping!") fail
repeatedly, and bad faith has been clearly shown.  (Neither of
which apply in this case.)


