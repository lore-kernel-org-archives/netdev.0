From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to
	submit to upper layer
Date: Sat, 14 Mar 2009 21:19:51 +0800
Message-ID: <20090314131951.GA6080@gondor.apana.org.au>
References: <65634d660903131459m645eb468y3ad850a1fd56d447@mail.gmail.com> <20090313.151913.21135937.davem@davemloft.net> <65634d660903131724s49009177pdc11005aa76a4b56@mail.gmail.com> <20090313.191951.228619450.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: therbert@google.com, yanmin_zhang@linux.intel.com,
	bhutchings@solarflare.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60282 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751674AbZCNNUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 09:20:07 -0400
Content-Disposition: inline
In-Reply-To: <20090313.191951.228619450.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2009 at 07:19:51PM -0700, David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Fri, 13 Mar 2009 17:24:10 -0700
> 
> > Enabling HW multi-queue has somewhat higher CPU
> > utilization though, the extra device interrupt load is not coming for
> > free.  We actually use the HW multi-queue in conjunction with our
> > software steering to get maximum pps (about 20% more).
> 
> This is a non-intuitive observation.  Using HW multiqueue should be
> cheaper than doing it in software, right?

Shared caches can play games with the numbers, we need to look
at this a bit more.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
