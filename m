From: P@draigBrady.com
Subject: Re: gettimeofday scalability
Date: Tue, 05 Oct 2004 20:16:33 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4162F311.4050009@draigBrady.com>
References: <4162CD76.4070204@draigBrady.com> <20041005185553.GG26820@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrea Arcangeli <andrea@novell.com>
In-Reply-To: <20041005185553.GG26820@dualathlon.random>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrea Arcangeli wrote:
> On Tue, Oct 05, 2004 at 05:36:06PM +0100, P@draigBrady.com wrote:
>=20
>>So can anyone summarise the relative merits of these locking
>>mechanisms, before I start benchmarking?
>=20
>=20
> frlock/seqlock (2.4/2.6 respectively) is the way to go, no write
> starvation, and zero cacheline bouncing.=20

Cheers.

Perhaps the confusing comment wrt brlock at the
top of seqlock.h can be changed so?

> upgrade to x86-64, there I implemented gettimeofday with vsyscalls whic=
h
> also avoids entering exiting userspace which becomes the by far biggest
> overhead after using seqlock. (speedup is tenfold or so)

This is all in kernel space.
However Stephen's suggestion of reading the tsc in user space
may be a runner, as I just care about relative times.

thanks guys!

P=E1draig.
