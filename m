From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 42012] New: regression on 2.6.39.3 with socket/bind;
 still there in 3.0.4
Date: Tue, 30 Aug 2011 21:16:43 +0200
Message-ID: <1314731803.2556.4.camel@edumazet-laptop>
References: <20110830084742.26c72c20@nehalam.ftrdhcpuser.net>
	 <1314720708.2935.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110830.140733.146208373221522199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54779 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756251Ab1H3TQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 15:16:47 -0400
Received: by wyg24 with SMTP id 24so5179892wyg.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 12:16:46 -0700 (PDT)
In-Reply-To: <20110830.140733.146208373221522199.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 ao=C3=BBt 2011 =C3=A0 14:07 -0400, David Miller a =C3=A9cri=
t :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 30 Aug 2011 18:11:48 +0200
>=20
> > Yep, we should relax the check and accept AF_UNSPEC.
>=20
> I guess we'll have to do this, but I just can't bring myself to accep=
t
> that we can just do zero validation of what the user is passing us,
> see an AF_UNSPEC, and say "yeah it's fine to assume there's an ipv4
> address in there."

I couldnt accept it either ;)

By the way, if we accept it, strace() will probably still print binary
blob instead of the IP address (not necessarily ANY address ?)

connect ( AF_UNSPEC ) has special semantic, but AFAIK, bind (AF_UNSPEC)
only brings some mixed results : FreeBSD was accepting it in old
versions it seems. I guess I should try current FreeBSD versions.
