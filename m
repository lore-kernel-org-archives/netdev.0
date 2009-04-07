From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 7 Apr 2009 22:17:08 +0800
Message-ID: <20090407141708.GA15253@gondor.apana.org.au>
References: <1238701718.5669.26.camel@bender> <20090407072647.GA11480@gondor.apana.org.au> <1239108520.32737.28.camel@dogo.mojatatu.com> <20090407130447.GA14329@gondor.apana.org.au> <1239112067.32737.51.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johann.baudy@gnu-log.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45646 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752120AbZDGOR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 10:17:28 -0400
Content-Disposition: inline
In-Reply-To: <1239112067.32737.51.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 07, 2009 at 09:47:47AM -0400, jamal wrote:
> On Tue, 2009-04-07 at 21:04 +0800, Herbert Xu wrote:
> 
> > Well through tc ipt actions you can invoke arbitrary netfilter
> > targets, including MARK --set-mark.
> 
> I thought you were saying this issue can be solved by 
> tc/mark but you meant tc/mark is one culprit;->
> Solvable by making sure tc/mark is not used in the system
> you are running an app using this feature.

Actually it's not just the tc ipt action.  If the target device
is a bridge then that too can invoke netfilter.  On the other hand
this is yet another feature that I've never really liked :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
