From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH 3/3] tcp_cubic: fix low utilization of CUBIC with HyStart
Date: Mon, 14 Mar 2011 07:28:24 +0100
Message-ID: <20110314062824.GA22755@xanadu.blop.info>
References: <1300061073-24209-1-git-send-email-sangtae.ha@gmail.com>
 <AANLkTi=bO+7d7W0O-m4=62xcM5P2qao9pzOyPJ1-jtox@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Injong Rhee <rhee@ncsu.edu>,
	Bill Fink <billfink@mindspring.com>, netdev@vger.kernel.org
To: Sangtae Ha <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:48781 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752158Ab1CNG1h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 02:27:37 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=bO+7d7W0O-m4=62xcM5P2qao9pzOyPJ1-jtox@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/03/11 at 19:07 -0500, Sangtae Ha wrote:
> Hi Lucas,
>=20
> Thank you for reporting this problem and the results below show what
> happened with low resolution clocks.
> The detailed testing setup and results at
> http://netsrv.csc.ncsu.edu/wiki/index.php/HyStart_testing_between_Pri=
nceton_and_NCSU
> I will add the results in long rtt paths soon.

Thanks. What do you use to generate those graphs?

The graphs from HyStart(fixed) are a bit strange. Did HyStart really
detect something? It seems that it exited slow start due to losses, not
due to detection, since cwnd is decreased.
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
