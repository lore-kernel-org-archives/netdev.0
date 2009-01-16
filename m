From: Divy Le Ray <divy@chelsio.com>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Fri, 16 Jan 2009 00:06:45 -0800
Message-ID: <49704015.6020503@chelsio.com>
References: <20090115235803.GA9000@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:20483 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753456AbZAPIH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 03:07:59 -0500
In-Reply-To: <20090115235803.GA9000@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Divy Le Ray <divy@chelsio.com> wrote:
>> Your patch looks fine. Early testing provides the same perfs
>> seen with LRO.
>>
>> I resubmit the original patch with 2 changes:
>> - cxgb3_set_flags() removal did not apply.
>>  commit 47fd23fe8efeea3af4593a8424419df48724eb25 had updated the routine.
>> - replace the NETIF_F_LRO features flag with NETIF_F_GRO
> 
> Thanks for the update Divy! It looks good to me.

Hi Herbert,

The perfs are not actually as good as with LRO.
With a slow server, 1 netperf stream gets on average:
without the patch, lro off: 3.8Gbs
without the patch, lro on: 6.1Gbs
with the patch, GRO on: 4.8Gbs.

I'll look into it.

Cheers,
Divy
