From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next-2.6] net: add support for htonb and ntohb
Date: Thu, 1 Apr 2010 20:03:44 -0400
Message-ID: <20100402000344.GB8930@hmsreliant.think-freely.org>
References: <20100401203209.GC28741@gospo.rdu.redhat.com>
 <1270154854.2192.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50913 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759019Ab0DBADu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 20:03:50 -0400
Content-Disposition: inline
In-Reply-To: <1270154854.2192.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 01, 2010 at 10:47:34PM +0200, Eric Dumazet wrote:
> Le jeudi 01 avril 2010 =E0 16:32 -0400, Andy Gospodarek a =E9crit :
> > After my recent post to net-2.6 this week to accidentally run htons=
 to a
> > u8, it is clear to me we _must_ add some infrastructure to make sur=
e
> > single bytes are in the correct network and host order on big and l=
ittle
> > endian systems.  Today seemed like the perfect day to post this.
> >=20
> > This patch adds basic support for htonb and ntohb.  Patches to add =
this
> > in the entire networking tree in _every_ case where a single byte i=
s
> > accessed will be posted next week -- I'm almost done with them!
> >=20
> > Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> > ---
>=20
> Seems fine, thanks a lot Andy.
>=20
> Hmm, I notice this doesnt handle yet arches where a byte is 9 bits lo=
ng.
>=20
> Do you have any plan, to finally support PDP-6/10 ?
>=20

definately, and while your at it, I could really use some conversion ro=
utines
for the more complex types just to save time.  htonstr and ntohstr in p=
articular




>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
