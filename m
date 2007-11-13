From: Mark Lord <liml@rtr.ca>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 17:29:09 -0500
Message-ID: <473A2535.7080304@rtr.ca>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113193750.GD1356@flint.arm.linux.org.uk> <473A067F.3090007@rtr.ca> <20071113213358.GC20167@lazybastard.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mark Lord <liml@rtr.ca>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-kernel@vger.kernel.org, protasnb@gmail.com,
	linux-ide@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20071113213358.GC20167@lazybastard.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

J=F6rn Engel wrote:
> On Tue, 13 November 2007 15:18:07 -0500, Mark Lord wrote:
>> I just find it weird that something can be known broken for several =
-rc*
>> kernels before I happen to install it, discover it's broken on my ow=
n machine,
>> and then I track it down, fix it, and submit the patch, generally al=
l within a
>> couple of hours.  Where the heck was the dude(ess) that broke it ?? =
 AWOL.
>>
>> And when I receive hostility from the "maintainers" of said code for=
 fixing
>> their bugs, well.. that really motivates me to continue reporting ne=
w ones..
>=20
> Given a decent bug report, I agree that having the bug not looked at =
is
> shameful.  But what can a developer do if a bug report effectively re=
ads
> "there is some bug somewhere in recent kernels"?  How can I know that=
 in
> this particular case it is my bug that I introduced?  It could just a=
s
> easily be 50 other people and none of them are eager to debug it unle=
ss
> they suspect it to be their bug.
=2E.

Most of the regressions we have are easily identifiable and not of the =
type
where there could "50 other people" touching the relevant code.  As a d=
eveloper
(and former subsystem maintainer) I look hard at my own code when there=
's a
bug reported that could have come from recent updates there.  Usually t=
here are
not that many updates to consider, and tracking it down is just a matte=
r of
being willing to do so.

Of late, I've given up on other developers fixing the stuff they break =
on my
own machines, and I generally just dive into totally unfamiliar code, a=
nd find
and fix it myself.  Quite quickly, usually.  And the bugs are often ver=
y apparent
just from looking at the source code diffs (patches) from recent histor=
y in
the code that's not working.  This is not rocket science, and it doesn'=
t require
a log2 download/rebuild/reboot process.

But yes, there are more difficult ones, like when my machine crashed ye=
sterday
with some form of corruption showing up during JBD filesystem I/O.  Tha=
t's one
where the problem isn't going to be obvious to anyone, and I don't actu=
ally
expect anyone to go looking for it right away.  If more such events hap=
pen,
then it will get more attention.

But things like broken drivers, in almost every case those are trivial
to track down and fix, even for people not familar with that specific c=
ode.

> This is a common problem and fairly unrelated to linux in general or =
the
> kernel in particular.  Who is going to be the sucker that figures out
> which developer the bug belongs to?  And I have yet to find a project=
,
> commercial or opensource, where volunteers flock to become such a
> sucker.
>=20
> One option is to push this role to the bug reporter.  Another is to
> strong-arm some developers into this role, by whatever means.  A thir=
d
> would be for $LARGE_COMPANY to hire some people.  If you have a bette=
r
> idea or would volunteer your time, I'd be grateful.  Simply blaming o=
ne
> side, whether bug reporter or a random developer, for not being the
> sucker doesn't help anyone.
=2E.

Nobody's blaming anyone here.  I'm just asking that developers here do =
more
like our Top Penguin does, and actually look at problems and try to und=
erstand
them and suggest fixes to try.  And not rely solely on the git-bisect c=
rutch.
It's a good crutch, provided the reporter is a kernel developer, or has=
 a lot
of time on their hands.  But we debugged Linux here for a long time wit=
hout it.

And I already volunteer my time here, thanks, BIG TIME, since 1992 or s=
o.

Cheers

