From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv4 net-next 3/8] {pktgen, xfrm} Correct xfrm_state_lock
 usage in xfrm_stateonly_find
Date: Thu, 2 Jan 2014 08:32:25 +0100
Message-ID: <20140102073225.GN31491@secunet.com>
References: <1387506814-4417-1-git-send-email-fan.du@windriver.com>
 <1387506814-4417-4-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hadi@cyberus.ca, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39054 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715AbaABHc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 02:32:28 -0500
Content-Disposition: inline
In-Reply-To: <1387506814-4417-4-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 10:33:29AM +0800, Fan Du wrote:
> ---
>  net/xfrm/xfrm_state.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 68c2f35..f7cb4a3 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -900,7 +900,7 @@ xfrm_stateonly_find(struct net *net, u32 mark,
>  	unsigned int h;
>  	struct xfrm_state *rx = NULL, *x = NULL;
>  
> -	spin_lock(&xfrm_state_lock);
> +	spin_lock_bh(&xfrm_state_lock);

This does not apply to ipsec-next, xfrm_state_lock is
now namespace aware. Please rebase your patchset to
ipsec-next current.

Thanks!
