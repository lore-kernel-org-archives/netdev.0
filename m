From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Sat, 6 Nov 2010 19:48:40 -0400
Message-ID: <20101106234840.GD2935@thunk.org>
References: <1289074307.3090.100.camel@Dan>
 <AANLkTimC01SViEOObgf2N2VcLTYO59rOAbHaKf2RM54w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Rosenberg <drosenberg@vsecurity.com>,
	"chas@cmf.nrl.navy.mil" <chas@cmf.nrl.navy.mil>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"remi.denis-courmont@nokia.com" <remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"security@kernel.org" <security@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from THUNK.ORG ([69.25.196.29]:39016 "EHLO thunker.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753300Ab0KFXts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Nov 2010 19:49:48 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTimC01SViEOObgf2N2VcLTYO59rOAbHaKf2RM54w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 06, 2010 at 01:50:32PM -0700, Linus Torvalds wrote:
> On Saturday, November 6, 2010, Dan Rosenberg <drosenberg@vsecurity.co=
m> wrote:
> > Clearly, in most cases we cannot just remove the field from the /pr=
oc
> > output, as this would break a number of userspace programs that rel=
y on
> > consistency. =A0However, I propose that we replace the address with=
 a "0"
> > rather than leaking this information.
>=20
> I really think it would be much better to use the unidentified number
> or similar.
>=20
> Just replacing with zeroes is annoying, and has the potential of
> losing actual information.

Are there any userspace programs that might be reasonably expected to
_use_ this information?  If there is, we could just pick a random
number at boot time, and then XOR the heap adddress with that random
number.

						- Ted
