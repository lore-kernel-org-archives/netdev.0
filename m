From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: LRO restructuring?
Date: Fri, 20 Feb 2009 08:37:25 +0800
Message-ID: <20090220003725.GA15980@gondor.apana.org.au>
References: <loom.20090218T192451-89@post.gmane.org> <20090219135358.GA11319@gondor.apana.org.au> <f0ed9b110902191417k2917d856q9098b304eeb7435b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan-Bernd Themann <themann@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>, netdev@vger.kernel.org
To: James Huang <jamesclhuang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44618 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752346AbZBTAhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 19:37:34 -0500
Content-Disposition: inline
In-Reply-To: <f0ed9b110902191417k2917d856q9098b304eeb7435b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2009 at 02:17:11PM -0800, James Huang wrote:
> Hi all,
> 
>     One question about inet_lro.c (linux 2.6.28.6)
> In lro_proc_segment(), it does not check the number of available frags
> entries in lro_desc->parent against the number of new fragments to be added
> before calling lro_add_frags().  Is that a bug?  I see that
> lro_proc_segment() does some type of checking at the end, but could that be
> too late (i.e. overflow the frags[])??
> 
>     Also I think some obvious optimization in lro_get_desc() can be done by
> combining the two for loops into one.

That file is obsolete.  The GRO code that will replace it lives
in various places:

	net/core/dev.c
	net/core/skbuff.c
	net/ipv4/af_inet.c
	net/ipv6/af_inet6.c
	net/ipv4/tcp_ipv4.c
	net/ipv6/tcp_ipv6.c
	net/ipv4/tcp.c
	net/8021q/vlan_core.c

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
