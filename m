From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Thu, 05 Nov 2009 08:10:00 +0100
Message-ID: <4AF27A48.4090001@gmail.com>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>	 <4AEEFE2E.7090706@trash.net> <20091102125345.3c39c42e@nehalam>	 <b30d1c3b0911031913k2c922935vc9605b76ac43168f@mail.gmail.com>	 <4AF10B1D.4050604@gmail.com> <4AF110CE.8070701@gmail.com>	 <b30d1c3b0911040019q14a007d4lbd1b695db8884b27@mail.gmail.com>	 <4AF1660E.1080401@gmail.com>	 <b30d1c3b0911040831y7aeac556raf7cae9106b5bc7b@mail.gmail.com>	 <4AF1B3CB.1050008@gmail.com> <b30d1c3b0911042308n616bc360v7b96b6543029f232@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Ryousei Takano <ryousei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52377 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbZKEHKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 02:10:04 -0500
In-Reply-To: <b30d1c3b0911042308n616bc360v7b96b6543029f232@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ryousei Takano a =E9crit :
> In my experiment, it is not very big problem.  I do not send short pa=
ckets.
> I got the almost same result in the both cases "mtu 64000" and "mtu
> 40000 quantum 60000".
>=20
> Anyway, setting larger mtu size than the physical mtu does not quiet =
make sense.
>=20

tc class mtu is a hint given to stack, about average packet size, ie no=
t
related to physical MTU (because of TSO)

You could use same mtu, but disable tso on device
