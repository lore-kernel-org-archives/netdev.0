From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: do the garbage collection after flushing policy
Date: Thu, 27 Apr 2017 09:27:13 +0200
Message-ID: <20170427072713.GW2649@secunet.com>
References: <b55e4ad516bc1be8fe70f68de028a4b32055e43f.1493019219.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: network dev <netdev@vger.kernel.org>, <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, <fw@strlen.de>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:53554 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933592AbdD0H1p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 03:27:45 -0400
Content-Disposition: inline
In-Reply-To: <b55e4ad516bc1be8fe70f68de028a4b32055e43f.1493019219.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 03:33:39PM +0800, Xin Long wrote:
> Now xfrm garbage collection can be triggered by 'ip xfrm policy del'.
> These is no reason not to do it after flushing policies, especially
> considering that 'garbage collection deferred' is only triggered
> when it reaches gc_thresh.
> 
> It's no good that the policy is gone but the xdst still hold there.
> The worse thing is that xdst->route/orig_dst is also hold and can
> not be released even if the orig_dst is already expired.
> 
> This patch is to do the garbage collection if there is any policy
> removed in xfrm_policy_flush.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied to the ipsec tree, thanks!
