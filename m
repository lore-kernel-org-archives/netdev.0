From: Ray Lehtiniemi <rayl@mail.com>
Subject: Re: 1.03Mpps on e1000
Date: Thu, 9 Dec 2004 16:25:50 -0700
Message-ID: <20041209232550.GE32454@mail.com>
References: <20041201213550.GF14470@xi.wantstofly.org> <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org> <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se> <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se> <20041208233617.GD8649@mail.com> <41B825A5.2000009@draigBrady.com> <20041209161825.GA32454@mail.com> <20041209164820.GB32454@mail.com> <41B8893B.5030407@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <41B8893B.5030407@draigBrady.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hi all

my apologies if this gets received twice... i originally sent a copy
of this using mutt's 'bounce' function, but i don't think that's
what i wanted to do.....

this is a bug report re: martin e1000 patch. i'm seeing some lockups
under normal traffic loads that seem to go away if i revert the
patch.  details below..


thanks



On Thu, Dec 09, 2004 at 05:19:55PM +0000, P@draigBrady.com wrote:
> Ray Lehtiniemi wrote:
> >On Thu, Dec 09, 2004 at 09:18:25AM -0700, Ray Lehtiniemi wrote:
> >
> >>it is worth noting that my box has become quite unstable since
> >>i started to use oprofile and pktgen together.  sshd stops responding=
,
> >>and the network seems to go down.  not sure what is happening there...
> >>this instability seems to be persisting across reboots, unfortunately=
...
> >
> >
> >
> >ok, it seems that this is related to martin's e1000 patch, and i
> >just hadn't noticed it before.  rolling back the 1.2 Mpps patch
> >seems to cure the problem.
> >
> >symptoms are a total freezeup of the e1000 interfaces. netstat
> >-an shows a tcp connection for my ssh login to the box, with about
> >53K in the send-Q.  /proc/net/tcp is empty, however....  i can
> >reproduce this at will by doing
> >
> > # objdump -d /lib/modules/2.6.10-rc3-mp-rayl/kernel/net/core/pktgen.k=
o
> >
> >on that machine with the e1000-patched kernel running.
> >
> >
> >if there's any diagnostic output i can generate that might tell
> >me what's going wrong, let me know and i'll try to generate it.
>=20
> can you send this to again to netdev.
>=20
> thanks.
>=20
> --=20
> P=E1draig Brady - http://www.pixelbeat.org
> --

--=20
----------------------------------------------------------------------
     Ray L   <rayl@mail.com>
