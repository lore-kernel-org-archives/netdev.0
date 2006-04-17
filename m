From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: softmac: semantics of SIOCSIWFREQ
Date: Mon, 17 Apr 2006 20:48:10 +0200
Message-ID: <1145299691.4116.11.camel@localhost>
References: <1145190888.6560.22.camel@localhost>
	 <20060417163759.GB28203@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-PVZXo9fUHak7VyjMZ9it"
Cc: netdev@vger.kernel.org, softmac-dev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:14516 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751203AbWDQSsP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 14:48:15 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060417163759.GB28203@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-PVZXo9fUHak7VyjMZ9it
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-04-17 at 09:37 -0700, Jean Tourrilhes wrote:

> 	Usually no, but...
> 	If you are in managed mode, SIOCSIWFREQ usually should return
> an error, because it is not allowed.

Ok.

> 	If you are in ad-hoc mode, SIOCSIWFREQ is used if a IBSS needs
> to be created. After scanning is done, if you did not find any
> network, you will create your own, and you will use the frequency that
> was set. You should never return an error.

Right. Well it should return an error if it is 'associated' in ad-hoc
mode too, no?


> 	The struct iw_scan_req has all the goodies you need to control
> scanning.

Right, so that's just a matter of using a different call to say where to
scan. Gotcha. IOW -- those people that want wardriving should use kismet
or whatever and properly control the driver via the iw_scan_req.

> 	The IW_FREQ_FIXED is mostly use for SIOCGIWFREQ, when
> getting. It tells you if the frequency was set by the user or
> automatically picked as the result of scanning.

Ah, but in which case is it set by the user? And is that 'fixed' then?

> 	I don't think any driver/hardware has the ability to set the
> frequency to auto, so IW_FREQ_FIXED is the default.

What would 'auto' be?

> 	It's because softmac only implements managed mode.

We might do some sort of ad-hoc client-only with Pete's patch, but we'll
never do master or wds I think.

> 	I've heard the call, I'll try to find some time for that.

Oh I was more thinking that I myself could add it somewhere after all
our discussion. If you do that, even better, but with the things we have
discussed already I can definitely help out.

johannes

--=-PVZXo9fUHak7VyjMZ9it
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUAREPi6aVg1VMiehFYAQLJRw/+L7SDc9eB2LCjN/lpXLe2FaFCY3FYQ3VW
1nFvRNp3hicbSIP+wH8HMcj2+vYXUNdpnwLip5qbto2HaIsyj3jHRFJIMf4YNu/h
D8Y3xMXffuoZKMP5xwZIti/48KuUJCDI52bRa/Tub/qT9wYF85Vi+yBm29SkNTy/
3EBQfl6OvPMeRqhiHWmRmM0CSsE6C6ntspLH4pVmsdKkwhRKTHl7JdiCG1MvrIej
FMHkT/pas/GW2xIuK6E+ay8z16ohJr0Rqnj2Oh5wk97fNvsuh5jgERmixSxPK1w5
4MhkDNFaJzOGgJsmVT7iycpZFc4K5R66lq/UdNmkJDNhXoFL+immi+k/lFl9pzRx
y712+zxc1HhPBpK+ywi/5S72RBzKTQJ0oLQBFNCFhengyLnLm9R/CCnRJhDHgqIV
IWI7jYjR4UlzQVfS08oYKHTJYCNLz3em1DRq/t9baXzmw/VH1AwxANBVOMQnUAaB
orwSb/z/MxYqOaBfz/vD/+pIrjnXX8GW/3PQ4IBMdAAUzmiwKnbOmTyMOc4PNXXb
I3Dwx5fMNnVcGwZMIYJFScuRCe2RnfG0+3MxgXI3XOkrE35NrggXsyGDVhALuAqU
LBfq1ZIBNog7V9CAodNiTJjWcaA2mzdaQaL2zqDKEtYbZvXPlA3TGjMdrifzY4DU
63jB4OyJTec=
=DFWZ
-----END PGP SIGNATURE-----

--=-PVZXo9fUHak7VyjMZ9it--

