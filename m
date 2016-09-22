From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] xfrm: state lookup can be lockless
Date: Thu, 22 Sep 2016 09:52:58 +0200
Message-ID: <20160922075258.GO31137@gauss.secunet.com>
References: <1474379126-32550-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:53471 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753488AbcIVHxb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 03:53:31 -0400
Content-Disposition: inline
In-Reply-To: <1474379126-32550-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 03:45:26PM +0200, Florian Westphal wrote:
> This is called from the packet input path, we get lock contention
> if many cpus handle ipsec in parallel.
> 
> After recent rcu conversion it is safe to call __xfrm_state_lookup
> without the spinlock.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied to ipsec-next, thanks a lot!
