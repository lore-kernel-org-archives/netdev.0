From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Fri, 16 Jul 2010 13:01:49 -0400
Message-ID: <1279299709.2156.5814.camel@tng>
References: <4C3D94E3.9080103@wildgooses.com> <4C3DD5EB.9070908@tmr.com>
	 <20100714.111553.104052157.davem@davemloft.net>
	 <AANLkTil3MVGwJUG12dikut9X1s9Ozc_3GwMjx_gErvxI@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, davidsen@tmr.com,
	lists@wildgooses.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:48091 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319Ab0GPRN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 13:13:26 -0400
In-Reply-To: <AANLkTil3MVGwJUG12dikut9X1s9Ozc_3GwMjx_gErvxI@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-07-14 at 21:51 -0700, H.K. Jerry Chu wrote:
>  except there are indeed bugs in the code today in that the
> code in various places assumes initcwnd as per RFC3390. So when
> initcwnd is raised, that actual value may be limited unnecessarily by
> the initial wmem/sk_sndbuf.

Thanks for the discussion!

can you tell us more about the impl concerns of initcwnd stored on the
route?

and while I'm asking for info, can you expand on the conclusion
regarding poor cache hit rates for reusing learned cwnds? (ok, I admit I
only read the slides.. maybe the paper has more info?)

article and slides much appreciated and very interetsing. I've long been
of the opinion that the downsides of being too aggressive once in a
while aren't all that serious anymore.. as someone else said in a
non-reservation world you are always trying to predict the future anyhow
and therefore overflowing a queue is always possible no matter how
conservative.




