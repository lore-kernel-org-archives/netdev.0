From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Tue, 8 Mar 2011 19:14:28 +0100
Message-ID: <20110308181428.GA12020@xanadu.blop.info>
References: <20110308093215.GA23842@xanadu.blop.info>
 <il4vur$3ka$1@dough.gmane.org>
 <20110308111011.GA27967@xanadu.blop.info>
 <AANLkTimdpEKHfVKw+bm6OnymcnUrauU+jGOPeLzy3Q0o@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: WANG Cong <xiyou.wangcong@gmail.com>, Injong Rhee <rhee@ncsu.edu>,
	Netdev <netdev@vger.kernel.org>
To: Sangtae Ha <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:57459 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753858Ab1CHSZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 13:25:38 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTimdpEKHfVKw+bm6OnymcnUrauU+jGOPeLzy3Q0o@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/11 at 11:43 -0500, Sangtae Ha wrote:
> Hi Lucas,
>=20
> The current packet-train threshold and the delay threshold have been =
tested
> with the bandwidth ranging from 10M to 400M, the RTT from 10ms to 320=
ms, and
> the buffer size from 10% BDP to 200% BDP and they were set conservati=
vely to
> make it work over the network with very small buffer sizes. I will re=
create
> your setup and check whether the current thresholds are too conservat=
ive and
> will come up with the patch.

I'm surprised. It's possible that a seemingly unrelated change broke it=
,
but it was already broken for me on 2.6.32.
I can provide access to the testbed if you want to run tests on it.
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
