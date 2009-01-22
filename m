From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 08:54:02 +0200
Message-ID: <4978180A.6080304@iki.fi>
References: <49780AA9.9050508@iki.fi> <20090121.220304.211246256.davem@davemloft.net> <49780EB5.60300@iki.fi> <20090121.222112.245293949.davem@davemloft.net> <20090122063206.GA11818@gondor.apana.org.au> <497814A7.3060302@iki.fi> <20090122064719.GA12043@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:40618 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbZAVGyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 01:54:09 -0500
Received: by fk-out-0910.google.com with SMTP id f33so560874fkf.5
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2009 22:54:05 -0800 (PST)
In-Reply-To: <20090122064719.GA12043@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jan 22, 2009 at 08:39:35AM +0200, Timo Ter=E4s wrote:
>> There hasn't been new release for ipsec-tools for a while.
>> It's been in ipsec-tools CVS since 2007-12-12. And I know many
>> who are using the CVS code in production.
>=20
> If they've had it since 2007 and only just realised that it
> doesn't work then it sounds like it doesn't really matter anyway.

That ipsec-tools feature works on *BSD. Works on Linux too
as kernel does not (yet) use that for anything except reporting
it back. Other OSes might use it already to e.g. fix-up the
packet checksums in transport mode SAs; I believe Linux just
recalculates the checksum.

The future patch I have in my mind I've been talking about,
does make use of NAT-OA. So that's why I noticed it only
just now. Btw, could someone comment on the idea of passing
NAT-OA to neighbour cache and make xfrm use it when choosing
which xfrm state to use?

- Timo

