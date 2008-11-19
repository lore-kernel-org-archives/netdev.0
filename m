From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make ip_rt_acct a normal percpu var
Date: Wed, 19 Nov 2008 14:20:23 -0800 (PST)
Message-ID: <20081119.142023.117741600.davem@davemloft.net>
References: <200811172050.31308.rusty@rustcorp.com.au>
	<4921F1DE.9080305@cosmosbay.com>
	<200811190208.11346.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36098
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750695AbYKSWUX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 17:20:23 -0500
In-Reply-To: <200811190208.11346.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 19 Nov 2008 02:08:10 +1030

> On Tuesday 18 November 2008 09:06:14 Eric Dumazet wrote:
> > Rusty Russell a =E9crit :
> > > There's no reason for this to be dynamically allocated: we panic =
if
> > > allocation fails anyway.
> > >
> > > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> >
> > Well, since we dont have "per_cpu bss", this also grow the size of =
vmlinux
> > file, with a block of 4096 nul bytes.
> ...
> > Maybe with current machines/boot loaders, we dont care anymore, I d=
ont
> > know...
>=20
> Good q.  If people care about on-disk size, maybe we should look at b=
zImage=20
> size?

It's the size of the final uncompressed loaded image that matters for
some bootloader limits.

I really don't like anything that increases the size like this, to be
honest.

Do you really need this to forward some work you are doing?  If not
can we just let sleeping dogs lie on this one? :)
