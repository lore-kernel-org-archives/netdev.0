From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
	ip_fragment
Date: Fri, 17 Sep 2010 14:51:17 +0800
Message-ID: <20100917065117.GA9577@gondor.apana.org.au>
References: <20100830200917.GA10754@stratus.com> <1283204118.2405.32.camel@edumazet-laptop> <20100830232147.GB10754@stratus.com> <1283232031.2405.38.camel@edumazet-laptop> <20100831082444.GB29281@gondor.apana.org.au> <1283246271.2550.35.camel@edumazet-laptop> <20100831123641.GA31017@gondor.apana.org.au> <20100901165743.GB17843@stratus.com> <20100903044941.GA28300@gondor.apana.org.au> <20100915173209.GB9086@stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bunk@kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Bandan Das <bandan.das@stratus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44538 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab0IQGvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 02:51:31 -0400
Content-Disposition: inline
In-Reply-To: <20100915173209.GB9086@stratus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 15, 2010 at 01:32:09PM -0400, Bandan Das wrote:
>
> Sorry for the late response. Here's a patch that I put up based on Herbert's
> suggestions. I ofcourse don't see the problem anymore after 
> commit 87f94b4e91dc042620c527f3c30c37e5127ef757 but a generic helper such as this 
> can be used anytime the bridge code is sending a packet over to the IP layer. 
> Compile tested only but based on responses, will test it before submitting a 
> final change. Also added it at two places where I know we do send a packet over to
> the IP layer. I will add it at other places later as I come across them.

Looks fine to me.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
