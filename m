From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Jumbo frame question...
Date: Sat, 25 Jul 2009 16:25:20 +0200
Message-ID: <4A6B15D0.9040804@gmail.com>
References: <200907241141.55097.rgetz@blackfin.uclinux.org> <200907241421.55986.rgetz@blackfin.uclinux.org> <4A6A07E5.9080705@gmail.com> <200907250834.34175.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50303 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbZGYO0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 10:26:46 -0400
In-Reply-To: <200907250834.34175.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robin Getz a =C3=A9crit :
> On Fri 24 Jul 2009 15:13, Eric Dumazet pondered:
>> I guess your tcpdump is fooled by gso settings... Did you tried
>> # ethtool -K eth0 gso off=20
>=20
> No -- that was the problem - my hardware trying to be too smart for m=
y software...
>=20
> Thanks for the help - sorry for the noise.

No problem, but I wonder why being 'too smart' was a problem in your ca=
se.
