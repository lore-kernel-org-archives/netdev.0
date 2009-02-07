From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: copyless virtio net thoughts?
Date: Sat, 7 Feb 2009 12:56:06 +0100
Message-ID: <200902071256.07513.arnd@arndb.de>
References: <20090205020732.GA27684@sequoia.sous-sol.org> <20090206091904.GA6645@gondor.apana.org.au> <498C4F6C.4070402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Chris Wright <chrisw@sous-sol.org>,
	Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:57137 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250AbZBGL5W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 06:57:22 -0500
In-Reply-To: <498C4F6C.4070402@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 06 February 2009, Avi Kivity wrote:
> > Well, these guests will suck both on baremetal and in virtualisatio=
n,
> > big deal :) Multiqueue at 10GbE speeds and above is simply not an
> > optional feature.
> > =A0=20
>=20
> Each guest may only use a part of the 10Gb/s bandwidth, if you have 1=
0=20
> guests each using 1Gb/s, then we should be able to support this witho=
ut=20
> multiqueue in the guests.

I would expect that there are people that even people with 10 simultane=
ous
guests would like to be able to saturate the link when only one or two =
of
them are doing much traffic on the interface.

Having the load spread evenly over all guests sounds like a much rarer
use case.

	Arnd <><
