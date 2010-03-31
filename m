From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] xfrm: increment genid before bumping state genids
Date: Wed, 31 Mar 2010 14:24:30 +0300
Message-ID: <4BB330EE.5020006@iki.fi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-3-git-send-email-timo.teras@iki.fi> <20100331105023.GA12845@gondor.apana.org.au> <4BB32A11.1030708@iki.fi> <4BB32B6F.7060403@iki.fi> <20100331111949.GD12845@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:64231 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757014Ab0CaLYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 07:24:32 -0400
Received: by ewy20 with SMTP id 20so1833462ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 04:24:30 -0700 (PDT)
In-Reply-To: <20100331111949.GD12845@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Mar 31, 2010 at 02:01:03PM +0300, Timo Ter=E4s wrote:
>> If any other xfrm_state_insert place needs to invalidate old
>> states it needs an additional bumping call. So the bumping function
>> is the right place to increment the genid.
>=20
> Right.  In fact, this thing doesn't need to be incremented on every
> insert.  How about this patch?
>=20
> xfrm: Remove xfrm_state_genid
>=20
> The xfrm state genid only needs to be matched against the copy
> saved in xfrm_dst.  So we don't need a global genid at all.  In
> fact, we don't even need to initialise it.
>=20
> Based on observation by Timo Ter=E4s.

Ah, yes. This is indeed better fix.

Thanks.
