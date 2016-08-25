From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] xfrm: state: remove per-netns gc task
Date: Thu, 25 Aug 2016 14:09:18 +0200
Message-ID: <20160825120918.GS3735@gauss.secunet.com>
References: <1471960812-25835-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45793 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933710AbcHYMJY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 08:09:24 -0400
Content-Disposition: inline
In-Reply-To: <1471960812-25835-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 23, 2016 at 04:00:12PM +0200, Florian Westphal wrote:
> After commit 5b8ef3415a21f173
> ("xfrm: Remove ancient sleeping when the SA is in acquire state")
> gc does not need any per-netns data anymore.
> 
> As far as gc is concerned all state structs are the same, so we
> can use a global work struct for it.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied to ipsec-next, thanks Florian!
