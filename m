From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 7 Apr 2009 21:04:47 +0800
Message-ID: <20090407130447.GA14329@gondor.apana.org.au>
References: <1238701718.5669.26.camel@bender> <20090407072647.GA11480@gondor.apana.org.au> <1239108520.32737.28.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johann.baudy@gnu-log.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58971 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752141AbZDGNFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 09:05:00 -0400
Content-Disposition: inline
In-Reply-To: <1239108520.32737.28.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 07, 2009 at 08:48:40AM -0400, jamal wrote:
>
> I see it as being non-trivial even with tc/mark. What did you
> have in mind? 

Well through tc ipt actions you can invoke arbitrary netfilter
targets, including MARK --set-mark.

In fact I've never really liked tc ipt actions since it doesn't
do any sanity checking on the packet before invoking the target
while normally netfitler does quite a bit of sanity checking.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
