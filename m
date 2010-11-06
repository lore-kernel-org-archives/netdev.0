From: David Miller <davem@davemloft.net>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Sat, 06 Nov 2010 16:57:03 -0700 (PDT)
Message-ID: <20101106.165703.193714684.davem@davemloft.net>
References: <1289074307.3090.100.camel@Dan>
	<AANLkTimC01SViEOObgf2N2VcLTYO59rOAbHaKf2RM54w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: drosenberg@vsecurity.com, chas@cmf.nrl.navy.mil,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	remi.denis-courmont@nokia.com, netdev@vger.kernel.org,
	security@kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45061
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753614Ab0KFX4k convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Nov 2010 19:56:40 -0400
In-Reply-To: <AANLkTimC01SViEOObgf2N2VcLTYO59rOAbHaKf2RM54w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 6 Nov 2010 13:50:32 -0700

> On Saturday, November 6, 2010, Dan Rosenberg <drosenberg@vsecurity.co=
m> wrote:
>>
>> Clearly, in most cases we cannot just remove the field from the /pro=
c
>> output, as this would break a number of userspace programs that rely=
 on
>> consistency. =A0However, I propose that we replace the address with =
a "0"
>> rather than leaking this information.
>=20
> I really think it would be much better to use the unidentified number
> or similar.
>=20
> Just replacing with zeroes is annoying, and has the potential of
> losing actual information.

I would really like to see the specific examples of where this is
happening, it sounds like something very silly to me.
