From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [XFRM]: constify 'struct xfrm_type'
Date: Thu, 24 Jan 2008 19:23:53 +0100
Message-ID: <4798D7B9.5090406@cosmosbay.com>
References: <20080124122621.3248c651.dada1@cosmosbay.com> <1201195057.16268.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003av.neufgp.fr ([84.96.92.124]:54127 "EHLO
	neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756319AbYAXS2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 13:28:50 -0500
In-Reply-To: <1201195057.16268.32.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches a =E9crit :
> On Thu, 2008-01-24 at 12:26 +0100, Eric Dumazet wrote:
>> -	struct xfrm_type *type;
>> +	const struct xfrm_type *type;
>=20
> Perhaps const foo * const bar; for most or all of these
> conversions?
>=20

Hum...

Having const data is nice because moving them from .data to .rodata,
but what would be practical gains to use a const pointer ???

