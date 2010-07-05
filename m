From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] tg3: 64bits stats
Date: Mon, 05 Jul 2010 18:31:10 +0100
Message-ID: <1278351070.2087.70.camel@achroite.uk.solarflarecom.com>
References: <1278321242.2877.18.camel@edumazet-laptop>
	 <1278345780.2877.376.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:58706 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960Ab0GERbN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 13:31:13 -0400
In-Reply-To: <1278345780.2877.376.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-07-05 at 18:03 +0200, Eric Dumazet wrote:
> Le lundi 05 juillet 2010 =C3=A0 11:14 +0200, Eric Dumazet a =C3=A9cri=
t :
> > After commit be1f3c2c027c (net: Enable 64-bit net device statistics=
 on
> > 32-bit architectures), we can now provide 64bit stats, even on 32bi=
t
> > arches.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
>=20
> Please disregard this patch.
>=20
> There is small possibility a reader might read a 64bit value while
> another writer makes a change to it, changing high 32bit value.
>=20
> A change in core network would be needed to make this 100% safe,
> possibly using a seqlock to protect dev->stats64

I really didn't want to add this overhead and complication to readers
when only some drivers need it.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

