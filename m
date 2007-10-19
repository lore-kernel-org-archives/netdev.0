From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netdev: Reset ipv4 flags during bundle creation on interfamily ipsec
Date: Fri, 19 Oct 2007 22:25:49 +0800
Message-ID: <E1IisnN-0003rh-00@gondolin.me.apana.org.au>
References: <200710191620.31168.joakim.koskela@hiit.fi>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: joakim.koskela@hiit.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4229 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752981AbXJSOZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 10:25:52 -0400
In-Reply-To: <200710191620.31168.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Koskela <joakim.koskela@hiit.fi> wrote:
>
> I'm not sure I follow. This affects the ipv6 bundling only where the struct 
> (fl_tunnel) has previously been used for ipv6 addresses. Not that we are 
> using the same block for holding the ipv4 info, the tos-value is really 
> undefined before we reset it.

You're right.  But sure the same bug could affect IPv4 as well
if you had a 4-6-4 configuration.  Let me think about this one
a bit more.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
