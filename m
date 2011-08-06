From: Tejun Heo <tj@kernel.org>
Subject: Re: [EXAMPLE CODE] Parasite thread injection and TCP connection
 hijacking
Date: Sat, 6 Aug 2011 15:20:52 +0200
Message-ID: <20110806132052.GE23937@htj.dyndns.org>
References: <20110806121247.GC23937@htj.dyndns.org>
 <4E3D3768.3070108@mit.edu>
 <20110806130037.GD23937@htj.dyndns.org>
 <CAObL_7FeZQpnOzpXHqSviZdBRUCL+rODbQOBb+6JPSd3PB=fig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Nathan Lynch <ntl@pobox.com>,
	Oren Laadan <orenl@cs.columbia.edu>,
	Daniel Lezcano <dlezcano@fr.ibm.com>, S@mit.edu,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAObL_7FeZQpnOzpXHqSviZdBRUCL+rODbQOBb+6JPSd3PB=fig@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sat, Aug 06, 2011 at 09:15:45AM -0400, Andrew Lutomirski wrote:
> On Sat, Aug 6, 2011 at 9:00 AM, Tejun Heo <tj@kernel.org> wrote:
> > Actually, the only thing we need on x86_64 is two bytes for the
> > syscall instruction because all params are passed through registers
> > anyway. =A0We can just set up parameters for mmap, turn on single s=
tep,
> > point %rip to syscall in the vsyscall page. =A0So, either way, I do=
n't
> > think this would be too difficult to solve.
>=20
> Not any more -- that syscall instruction is gone as of 3.1.  You coul=
d
> search through the vdso to find a syscall, but that seems fragile.
>=20
> Why not just add a ptrace command to issue a syscall?

Yeah, maybe.  If this thing proves to be useful enough and looking for
a page to poke under proc too cumbersome.  I'm not against it but
don't really see strong need either at this point.

Thanks.

--=20
tejun
