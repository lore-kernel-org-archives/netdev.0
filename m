From: Nelson Elhage <nelhage@ksplice.com>
Subject: Re: [PATCH] pktgen: Remove a dangerous debug print.
Date: Wed, 27 Oct 2010 15:49:05 -0400
Message-ID: <20101027194905.GQ16803@ksplice.com>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
 <20101027.122143.02260950.davem@davemloft.net>
 <20101027192808.GP16803@ksplice.com>
 <1288208499.2658.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eugene@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1288208499.2658.19.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I tested this and was able to oops both amd64 and i386 test machines wi=
th 8k
writes to the pktgen file. I haven't investigated whether that's becaus=
e there's
no PAGE_SIZE limit, or because one page ends up being enough to cause a=
 problem
on all my test machines.

- Nelson

On Wed, Oct 27, 2010 at 09:41:39PM +0200, Eric Dumazet wrote:
> Le mercredi 27 octobre 2010 =E0 15:28 -0400, Nelson Elhage a =E9crit =
:
> > How would you feel about limiting the debug print to at most, say, =
512 or 1024
> > bytes? Even if it's only accessible to root by default, I don't a u=
serspace
> > program should be able to accidentally corrupt the kernel stack by =
writing too
> > many bytes to a file in /proc.
>=20
> Arent /proc writes limited to PAGE_SIZE anyway ?
>=20
> On x86 at least, you cannot corrupt kernel stack, since its bigger th=
an
> PAGE_SIZE.
>=20
> I agree pktgen code is a bit ugly and needs a cleanup, but who
> cares ? :)
>=20
>=20
>=20
>=20
