From: Vitaliy Gusev <vgusev@openvz.org>
Subject: Re: [PATCH] route: Fix caught BUG_ON during rt_secret_rebuild_oneshot()
Date: Tue, 16 Mar 2010 18:27:08 +0300
Message-ID: <201003161827.08595.vgusev@openvz.org>
References: <201003161407.51925.vgusev@openvz.org> <20100316143437.GA8225@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:48394 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756383Ab0CPPWS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Mar 2010 11:22:18 -0400
In-Reply-To: <20100316143437.GA8225@hmsreliant.think-freely.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 March 2010 05:34:37 pm Neil Horman wrote:
...
> Yeah, this seems reasonable.  Although this might be a good time to bring up the
> subject of deprecating or removing the secret interval.  We've had our
> statistical analysis bits in place to drive the rebuilding of the cache in the
> event that any one chain gets too long, and in the year or so that we've had it,
> it seems we've shaken out a few bugs with it (which suggests that people are
> using it routinely).  As such, might it be time to just drop the rebuild timer
> in its entirety?

Rebuild timer was introduced by secure reason when there was no analysis for
chain lenght. Now it seems that rebuild timer can be removed.


> 
> Until that decision is made of course, the above seems like a sane fix for it.
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 



Thanks,
Vitaliy Gusev
