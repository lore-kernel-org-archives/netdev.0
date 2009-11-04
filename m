From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Wed, 04 Nov 2009 06:27:42 +0100
Message-ID: <4AF110CE.8070701@gmail.com>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>	 <4AEEFE2E.7090706@trash.net> <20091102125345.3c39c42e@nehalam> <b30d1c3b0911031913k2c922935vc9605b76ac43168f@mail.gmail.com> <4AF10B1D.4050604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Ryousei Takano <ryousei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60316 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbZKDF1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 00:27:46 -0500
In-Reply-To: <4AF10B1D.4050604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
>=20
> Hmm, do you know part of the error comes from the user tool itself ?
>=20
> If you check iperf results at sender and receiver you'll see differen=
t
> values, sender lies a bit.
>=20
> Tried here on a Gbit link (I dont have 10Gbe yet)
>=20
> $ ./iperf.bench.sh
> .100 104
> .200 206
> .300 307
> .400 413
> .500 515
> .600 610
> .700 715
> .800 822
> .900 913
> 1.000 945
>=20
(that was with standard 1500 MTU)

Now, with 9000 MTU and 50 seconds samples (instead of 5 s) I get :

$ ./iperf.bench.sh
=2E100 101
=2E200 200
=2E300 301
=2E400 401
=2E500 500
=2E600 601
=2E700 700
=2E800 803
=2E900 903
1.000 991

Not too bad :)
