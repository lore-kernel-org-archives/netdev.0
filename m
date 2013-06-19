From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-next,v5,2/3] bridge: only expire the mdb entry when query
 is received
Date: Wed, 19 Jun 2013 12:44:38 +0800
Message-ID: <20130619044438.GA8174@gondor.apana.org.au>
References: <1369209176-6841-2-git-send-email-amwang@redhat.com>
 <20130618120338.GA9063@Linus-Debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Amerigo Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38924 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932873Ab3FSEot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 00:44:49 -0400
Content-Disposition: inline
In-Reply-To: <20130618120338.GA9063@Linus-Debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 18, 2013 at 02:03:38PM +0200, Linus L=FCssing wrote:
> Hi Amerigo,
>=20
> I just tested these three patches on top of 3.10-rc6 (thanks for
> looking into these issues so far!) but unfortunately I'm still
> having problems if there is no querier on the link:
>=20
> We will never discover a multicast listener which sends its
> startup MLD reports before being attached to the bridge port.
>=20
> I had reported that issue two months ago to Herbert's patch which
> changed the querier default [1].
>=20
> I guess in such a scenario where neither our querier is activated
> nor could we detect any querier, then the only safe thing we can
> do is to disable the bridge multicast snooping, isn't it?

If we have seen no queries then we should simply flood.  The fact
that we don't currently is a bug.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
