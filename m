From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch net-next v2 0/5] neigh: respect default parms values
Date: Mon, 9 Dec 2013 19:52:27 +0800
Message-ID: <20131209115226.GA1206@gondor.apana.org.au>
References: <1386440817-7846-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org, gaofeng@cn.fujitsu.com,
	joe@perches.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40169 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760292Ab3LILwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 06:52:40 -0500
Content-Disposition: inline
In-Reply-To: <1386440817-7846-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 07, 2013 at 07:26:52PM +0100, Jiri Pirko wrote:
> This is a long standing regression. But since the patchset is bigger and
> the regression happened in 2007, I'm proposing this to net-next instead.
> 
> Basically the problem is that if user wants to use /etc/sysctl.conf to specify
> default values of neigh related params, he is not able to do that.
> 
> The reason is that the default values are copied to dev instance right after
> netdev is registered. And that is way to early. The original behaviour
> for ipv4 was that this happened after first address was assigned to device.
> For ipv6 this was apparently from the very beginning.
> 
> So this patchset basically reverts the behaviour back to what it was in 2007 for
> ipv4 and changes the behaviour for ipv6 so they are both the same.
> 
> v1->v2:
> - use neigh_parms->tbl->family as suggested by davem
> 
> Jiri Pirko (5):
>   neigh: convert parms to an array
>   neigh: wrap proc dointvec functions
>   neigh: use tbl->family to distinguish ipv4 from ipv6
>   neigh: restore old behaviour of default parms values
>   neigh: ipv6: respect default values set before an address is assigned
>     to device

I haven't studied the patches in detail but the idea certainly
sounds good to me.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
