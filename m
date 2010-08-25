From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] gro: __napi_gro_receive() optimizations
Date: Wed, 25 Aug 2010 22:54:33 +0200
Message-ID: <1282769673.2681.170.camel@edumazet-laptop>
References: <1282768431.2681.144.camel@edumazet-laptop>
	 <20100825134547.0ecc4f11@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36328 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233Ab0HYUyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 16:54:39 -0400
Received: by bwz11 with SMTP id 11so721468bwz.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 13:54:38 -0700 (PDT)
In-Reply-To: <20100825134547.0ecc4f11@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 ao=C3=BBt 2010 =C3=A0 13:45 -0700, Stephen Hemminger a =C3=
=A9crit :
> On Wed, 25 Aug 2010 22:33:51 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > compare_ether_header() can have a special implementation on 64 bit
> > arches if CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is defined
> >=20
> > __napi_gro_receive() can avoid a conditional branch to perform devi=
ce
> > match.
> >=20
> > __napi_gro_receive() can be used from vlan_gro_common() instead of =
being
> > duplicated.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Please, 2 patches. not mixing unrelated bits in one patch.


Well, all this stuff was added in a single commit,=20

commit aa4b9f533ed5a22952e038b9fac2447ccc682124
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sun Feb 8 18:00:37 2009 +0000

    gro: Optimise Ethernet header comparison


But yes, I guess I can cook three different patches, if you feel its
better this way...



