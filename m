From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Connection tracking and vlan
Date: Fri, 30 Oct 2009 11:46:39 -0400
Message-ID: <20091030154639.GA8197@gondor.apana.org.au>
References: <20091030152054.GA7936@gondor.apana.org.au> <4AEB06E6.6020206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adayadil Thomas <adayadil.thomas@gmail.com>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44317 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752117AbZJ3Pqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 11:46:36 -0400
Content-Disposition: inline
In-Reply-To: <4AEB06E6.6020206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2009 at 04:31:50PM +0100, Eric Dumazet wrote:
>
> Same thing if you have two interfaces, eth0 & eth1 : IP conntrack tuples dont
> include interface name/index

Indeed, but imagine what happens when eth0 is the LAN and eth1 is
the wild wild Internet.  Do you really want their packets to mix?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
