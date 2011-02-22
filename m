From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: why all packets have same queue no when rps enabled?
Date: Tue, 22 Feb 2011 13:09:25 +0000
Message-ID: <1298380165.2211.481.camel@localhost>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24D3DE6D0C@MILEXCH2.ds.jdsu.net>
	 <1298378756.2211.478.camel@localhost>
	 <1298379718.2861.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Zhou <Jon.Zhou@jdsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:3049 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149Ab1BVNJa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 08:09:30 -0500
In-Reply-To: <1298379718.2861.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-22 at 14:01 +0100, Eric Dumazet wrote:
> Le mardi 22 f=C3=A9vrier 2011 =C3=A0 12:45 +0000, Ben Hutchings a =C3=
=A9crit :
>=20
> > The queue number identifies a hardware queue.  RPS therefore does n=
ot
> > update this number when queueing packets for processing on other CP=
Us.
> >=20
> > If the hardware/driver provides a receive hash (probably Toeplitz) =
then
> > this is used for RPS.  Otherwise a much cheaper hash is used.
>=20
> The default is/should be : rxhash generated in network stack.
>=20
> ethtool -k eth0 | grep hash
> receive-hashing: off
>=20
> To use the device/harwdare provided rxhash, you need to ask for it.
>=20
> ethtool -K eth0 rxhash on

Whether this is enabled by default depends on the driver.

> BTW, I am not sure what you mean by "much cheaper hash is used"...
>=20
> I presume hardware provided hash is less expensive (for our cpu) than
> computing our rxhash...

I mean the hash function we use is much cheaper than Toeplitz.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

