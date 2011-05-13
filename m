From: Christian Couder <christian.couder@gmail.com>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up hard
 right after logging in)
Date: Fri, 13 May 2011 10:20:54 +0200
Message-ID: <BANLkTikMeyRTOB9q4PEAYWnZRZfk3wg=kQ@mail.gmail.com>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	git@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Shuang He <shuang.he@intel.com>
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2011 at 7:15 PM, Andrew Lutomirski <luto@mit.edu> wrote=
:
>
> OK, this sucks. =A0In the course of bisecting this, I've hit two othe=
r
> apparently unrelated bugs that prevent my from testing large numbers
> of kernels. =A0Do I have two questions:
>
> 1. Anyone have any ideas from looking at the log?
>
> It looks like most of what's left is network code, so cc netdev.
>
> 2. =A0The !&$#@ bisection is skipping all over the place. =A0I've see=
n
> 2.6.37 versions and all manner of -rc's out of order. =A0Linus, and
> other people who like pontificating about git bisection: is there any
> way to get the bisection to follow Linus' tree? =A0I think that if
> bisect could be persuaded to consider only changes that are reached b=
y
> following only the *first* merge parent all the way from the bad
> revision to the good revision, then the bisection would build version=
s
> that were at least good enough for Linus to pull and might have fewer
> bisection-killing bugs.
>
> (This isn't a new idea [1], and git rev-list --bisect --first-parent
> isn't so bad except that it doesn't bisect.)

Did you forget to put the reference [1] in your email? Was it this one
you were thinking about:

http://thread.gmane.org/gmane.comp.version-control.git/165433/

?

Thanks,
Christian.
