From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Sat, 15 Apr 2006 01:58:16 +1000
Message-ID: <E1FUQga-0000U4-00@gondolin.me.apana.org.au>
References: <20060414000129.GB23116@bougret.hpl.hp.com>
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from CyborgDefenseSystems.Corporatebeast.com ([64.62.148.172]:49168
	"EHLO arnor.apana.org.au") by vger.kernel.org with ESMTP
	id S1751260AbWDNP62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 11:58:28 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060414000129.GB23116@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean Tourrilhes <jt@hpl.hp.com> wrote:
> 
>        We have the message interface (through a Wireless Events,
> since WE-14). However, netlink is highly undesirable in embedded space
> for bloat reason.

Why is that? I've seen many embedded applications using netlink
for either routing or IPsec.  It doesn't take much code at all
to do netlink.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
