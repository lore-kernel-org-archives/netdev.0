From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] NET: Multiqueue network device support.
Date: Wed, 11 Apr 2007 20:49:43 +1000
Message-ID: <E1HbaOV-0004rc-00@gondolin.me.apana.org.au>
References: <D5C1322C3E673F459512FB59E0DDC329029E3EE5@orsmsx414.amr.corp.intel.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com, cramerj@intel.com,
	auke-jan.h.kok@intel.com, christopher.leech@intel.com
To: peter.p.waskiewicz.jr@intel.com (Waskiewicz Jr, Peter P)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3159 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752185AbXDKKt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 06:49:57 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329029E3EE5@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> wrote:
> 
> True, but the assignment for "dev" above also casts this void * to
> struct net_device *:
> 
>        dev = (struct net_device *)
>                (((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
>        dev->padded = (char *)dev - (char *)p;
> 
> Shall I remove my cast?

This is totally different as it's casting a "long", not a "void *".

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
