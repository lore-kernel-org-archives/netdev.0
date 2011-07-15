From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 07/10] net: remove NETIF_F_NO_CSUM feature
Date: Fri, 15 Jul 2011 02:28:42 +0200
Message-ID: <20110715002842.GA19328@rere.qmqm.pl>
References: <20110714205623.GD16759@rere.qmqm.pl>
 <20110714.143121.1603730405553208694.davem@davemloft.net>
 <20110714224445.GA18237@rere.qmqm.pl>
 <20110714.170506.1425372007221475085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53082 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932409Ab1GOA2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 20:28:43 -0400
Content-Disposition: inline
In-Reply-To: <20110714.170506.1425372007221475085.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2011 at 05:05:06PM -0700, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Fri, 15 Jul 2011 00:44:45 +0200
>=20
> > On Thu, Jul 14, 2011 at 02:31:21PM -0700, David Miller wrote:
> >> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> >> Date: Thu, 14 Jul 2011 22:56:23 +0200
> >> > That's why its turned off by default and should be enabled only =
when user
> >> > knows he will win some pps with it.
> >> More people are going to lose than win by your change.
> >>=20
> >> The nocopy feature helps more real situations than it hurts, the
> >> existing default is the best.
> >=20
> > I see. I still want to remove NO_CSUM (as I explained in other mail=
),
> > so would you accept replacing it with something more specific to
> > nocache-copy feature? READS_DATA maybe? That could be later added t=
o
> > sk_route_caps whenever it's known for a route there will be need to
> > read packets' data.
>=20
> I don't actually see what the problem is.
>=20
> The code wants to conditionalize the nocache-copy feature based upon
> whether hardware will checksum the packet or not.
>=20
> And that's exactly what it's testing.
>=20
> The reason, of course, is because it doesn't want to enable
> nocache-copy if the cpu is just going to read the data back into it's
> caches during the checksum.  But that's no reason to change the
> flag name to have the word "read" instead of "checksum" in it.

But the real condition is that CPU doesn't read the data. I doesn't mat=
ter
if reading is to calculate the checksum or parsing it. The change would
make this obvious.

BTW,=20
Best Regards,
Micha=B3 Miros=B3aw
