From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] ipv6: use a random ifid for headerless devices
Date: Fri, 04 Dec 2015 11:41:52 +0100
Message-ID: <1449225712.287884.457895729.21AD000E@webmail.messagingengine.com>
References: <1448884508-5235-1-git-send-email-bjorn@mork.no>
 <1448968942.3320842.454553905.2C5FBADD@webmail.messagingengine.com>
 <87vb8fjpou.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:51735 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752283AbbLDKlx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 05:41:53 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 7C33E2094A
	for <netdev@vger.kernel.org>; Fri,  4 Dec 2015 05:41:52 -0500 (EST)
In-Reply-To: <87vb8fjpou.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Dec 3, 2015, at 20:29, Bj=C3=B8rn Mork wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>=20
> > I see no problem with the patch as it eases operating those devices=
=2E I
> > would also suggest storing the ifid in the inet6_dev so it does onl=
y
> > change during device creation and destruction. Otherwise I would
> > recommend to use stable privacy addresses to generate the link loca=
l
> > addresses. EUI-48 based LL creation should hopefully not be used an=
ymore
> > soon.
>=20
> Thanks for commenting on this. Yes, the stable privacy addresses look=
s
> like they will solve this and other problems.  But enabling them requ=
ire
> an adminstrator action.
>=20
> After looking more at addrconf, I started wondering if we couldn't ab=
use
> ipv6_generate_stable_address() for this purpose?  We could add a new
> addr_gen_mode which would trigger automatic generation of a secret if
> stable_secret is uninitialized.  This would be good enough to ensure
> stability until the interface is destroyed.  And it would still allow
> the adminstrator to select IN6_ADDR_GEN_MODE_STABLE_PRIVACY by enteri=
ng
> a new secret.

I am fine with your proposal but I would really like to see it only
happen on the per-interface stable_secret instance.

Thanks,
Hannes
