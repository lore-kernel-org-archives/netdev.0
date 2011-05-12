From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice.h: Align struct netdevices members
Date: Thu, 12 May 2011 15:05:39 -0700 (PDT)
Message-ID: <20110512.150539.189697453.davem@davemloft.net>
References: <1304998966.19586.104.camel@Joe-Laptop>
	<1304999595.3050.45.camel@edumazet-laptop>
	<1305001325.19586.110.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37087
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758813Ab1ELWGL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 18:06:11 -0400
In-Reply-To: <1305001325.19586.110.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Joe Perches <joe@perches.com>
Date: Mon, 09 May 2011 21:22:05 -0700

> On Tue, 2011-05-10 at 05:53 +0200, Eric Dumazet wrote:
>> Le lundi 09 mai 2011 =E0 20:42 -0700, Joe Perches a =E9crit :
>> > Save a bit of space.
>> Hmm... correct alignements are far more important for this structure=
=2E
>=20
> I agree.  I aligned these members on "natural" boundaries.
> 4 consecutive chars rather than 2 chars, unsigned long.
> =20
>> Did you run benchmarks on 32bit and 64bit platforms ?
>=20
> Nope.
>=20
>> BTW we have ____cacheline_aligned_in_smp markers, I am not even sure
>> this patch saves space.
>=20
> That depends on whether or not CONFIG_SMP is defined and
> all of the changes are before any ____cacheline_aligned markers.

I think this is sane, Eric do you still have objections?
