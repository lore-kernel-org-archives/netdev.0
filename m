From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 14:43:20 -0800
Message-ID: <20071113144320.a83255ed.akpm@linux-foundation.org>
References: <20071113.033946.114918709.davem@davemloft.net>
	<20071113034916.2556edd7.akpm@linux-foundation.org>
	<20071113.035824.40509981.davem@davemloft.net>
	<20071113041259.79c9a8c5.akpm@linux-foundation.org>
	<20071113134029.GA30978@elte.hu>
	<4739AFE0.20705@rtr.ca>
	<20071113193750.GD1356@flint.arm.linux.org.uk>
	<473A067F.3090007@rtr.ca>
	<20071113213358.GC20167@lazybastard.org>
	<20071113135658.5c9ac7ba.akpm@linux-foundation.org>
	<20071113222414.GD20167@lazybastard.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Mark Lord <liml@rtr.ca>, Ingo Molnar <mingo@elte.hu>,
        alsa-devel@alsa-project.org, netdev@vger.kernel.org,
        linux-pcmcia@lists.infradead.org, linux-kernel@vger.kernel.org,
        protasnb@gmail.com, linux-ide@vger.kernel.org,
        bugme-daemon@bugzilla.kernel.org, linux-input@atrey.karlin.mff.cuni.cz,
        David Miller <davem@davemloft.net>
To: =?ISO-8859-1?B?SvZybg==?= Engel <joern@logfs.org>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113222414.GD20167@lazybastard.org>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2007 23:24:14 +0100 J=F6rn Engel <joern@logfs.org> wrote:

> On Tue, 13 November 2007 13:56:58 -0800, Andrew Morton wrote:
> >=20
> > It's relatively common that a regression in subsystem A will manifest a=
s a
> > failure in subsystem B, and the report initially lands on the desk of t=
he
> > subsystem B developers.
> >=20
> > But that's OK.  The subsystem B people are the ones with the expertise =
to
> > be able to work out where the bug resides and to help the subsystem A
> > people understand what went wrong.
> >=20
> > Alas, sometimes the B people will just roll eyes and do nothing because
> > they know the problem wasn't in their code.  Sometimes.
>=20
> And sometimes the A people will ignore the B people after the root cause
> has been worked out.  Do you have a good idea how to shame A into
> action?  Should I put you on Cc:?  Right now I'm in the eye-rolling
> phase.
>=20

Well, that's the problem, isn't it?

The best I can come up with is to suggest that all the info be captured in
a bugzilla report so that at least it doesn't get forgotten about.

I suppose that other options are

a) try to fix it yourself.  I'll take the patch and as long as we make a
   big enough mess of it, someone who knows what they're doing might fix it
   for real.

b) If it was a regression, identify the offending commit and we'll just
   revert it.
