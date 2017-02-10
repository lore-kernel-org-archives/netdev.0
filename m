From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] xfrm: input: constify xfrm_input_afinfo
Date: Fri, 10 Feb 2017 08:37:03 +0100
Message-ID: <20170210073702.GZ30338@gauss.secunet.com>
References: <20170207135230.19609-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:47032 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750979AbdBJHhK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 02:37:10 -0500
Content-Disposition: inline
In-Reply-To: <20170207135230.19609-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 02:52:30PM +0100, Florian Westphal wrote:
> Nothing writes to these structures (the module owner was not used).
> 
> While at it, size xfrm_input_afinfo[] by the highest existing xfrm family
> (INET6), not AF_MAX.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied to ipsec-next, thanks!
