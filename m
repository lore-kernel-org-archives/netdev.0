From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 08:09:37 +0100
Message-ID: <4AFD0631.9020802@gmail.com>
References: <200911130701.14847.opurdila@ixiacom.com>	<200911130720.19671.opurdila@ixiacom.com>	<4AFCF8D3.6090905@gmail.com> <20091112222608.79d90e9e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60847 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799AbZKMHJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 02:09:35 -0500
In-Reply-To: <20091112222608.79d90e9e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :
> No one has give a reasonable use case for this network device name
> explosion, what is the benchmark doing this nosense, and how do I
> get paid to do it...
>=20
> But I have to say no for another reason. You cause the kernel to choo=
se
> a different name for the case where a device is deleted or renamed.
> The old code would find and fill the hole when a new device was added=
=2E
>=20
> Since this is a semantic ABI change, the kind that drives users nuts.
>=20

Yes, I see your point Stephen, but it would be trivial to skip already
used devices as well with litle change.


