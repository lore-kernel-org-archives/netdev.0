From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec] xfrm: unbreak xfrm_sk_policy_lookup
Date: Fri, 18 Nov 2016 10:17:47 +0100
Message-ID: <20161118091746.GC19080@gauss.secunet.com>
References: <1479385306-24731-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:44502 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753065AbcKRJRx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Nov 2016 04:17:53 -0500
Content-Disposition: inline
In-Reply-To: <1479385306-24731-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2016 at 01:21:46PM +0100, Florian Westphal wrote:
> if we succeed grabbing the refcount, then
>   if (err && !xfrm_pol_hold_rcu)
> 
> will evaluate to false so this hits last else branch which then
> sets policy to ERR_PTR(0).
> 
> Fixes: ae33786f73a7ce ("xfrm: policy: only use rcu in xfrm_sk_policy_lookup")
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied to the ipsec tree, thanks everyone!
