From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6,
 token: allow for clearing the current device token
Date: Fri, 08 Apr 2016 16:33:58 +0200
Message-ID: <1460126038.1452331.572938089.68D8127C@webmail.messagingengine.com>
References: <307b4d32099f606d0fbe0ce9fecd3a039b796361.1460123261.git.daniel@iogearbox.net>
 <878u0otc96.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, robbat2@gentoo.org, netdev@vger.kernel.org
To: =?UTF-8?Q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60767 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751812AbcDHOd7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 10:33:59 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id A3B9720D76
	for <netdev@vger.kernel.org>; Fri,  8 Apr 2016 10:33:58 -0400 (EDT)
In-Reply-To: <878u0otc96.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, Apr 8, 2016, at 16:18, Bj=C3=B8rn Mork wrote:
> Daniel Borkmann <daniel@iogearbox.net> writes:
>=20
> > =20
> >  	if (!token)
> >  		return -EINVAL;
> > -	if (ipv6_addr_any(token))
> > -		return -EINVAL;
> >  	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP))
> >  		return -EINVAL;
>=20
> Not directly related to the patch in question.  It just made me aware=
 of
> this restriction...
>=20
> I realize that I'm a few years late here, but what's with the IFF_NOA=
RP?
> Is that just because we can't do DAD for the token based addresses?  =
How
> is that different from manually configuring the whole address?

IFF_NOARP is kind of the equivalent to no neighbor discovery. If you se=
t
a token and never get in a router advertisement you never create a
tokenized ip address, thus the feature is useless.

Bye,
Hannes
