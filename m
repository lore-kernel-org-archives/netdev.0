From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Wed, 23 Sep 2015 23:41:16 -0400
Message-ID: <20150924034116.GC26853@htj.duckdns.org>
References: <20150922161056.GB9761@mtj.duckdns.org>
 <20150923061342.GA19106@gondor.apana.org.au>
 <20150923155440.GB26647@mtj.duckdns.org>
 <20150924023010.GA27131@gondor.apana.org.au>
 <20150924024608.GA25502@htj.duckdns.org>
 <20150924025435.GB27355@gondor.apana.org.au>
 <20150924030609.GA26853@htj.duckdns.org>
 <20150924032100.GA27649@gondor.apana.org.au>
 <20150924032928.GB26853@htj.duckdns.org>
 <20150924033117.GA27754@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:35582 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932352AbbIXDlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 23:41:21 -0400
Content-Disposition: inline
In-Reply-To: <20150924033117.GA27754@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 11:31:17AM +0800, Herbert Xu wrote:
> No this isn't what happened.  My error was trying to see if there
> is a way to do it without barriers.  In the end there wasn't.  This
> has nothing to do with using primitives.

Hmmm... yeah, you can say that, but it still was a failure to
recognize and apply the common pattern and what you're suggesting is
deviating for no good reason.  It demands a lot of cognitive overhead
for something which should be routine and makes the code a lot more
fragile as a result.  Things like this make barrier usages difficult
to understand and verify because it takes away a lot of ready-made
cognitive tools.  So, let's please stick to the known pattern.

Thanks.

-- 
tejun
