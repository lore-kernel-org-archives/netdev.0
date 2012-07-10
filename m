From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] bridge: netfilter: fix skb->nf_bridge NULL panic in
 br_nf_forward_finish
Date: Tue, 10 Jul 2012 17:41:09 +0900
Message-ID: <20120710084103.GA27117@verge.net.au>
References: <1341622087.4004.2.camel@chief-river-32>
 <alpine.LFD.2.00.1207071229010.1595@ja.ssi.bg>
 <1341655223.7993.3.camel@chief-river-32>
 <alpine.LFD.2.00.1207071322490.5927@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lin Ming <mlin@ss.pku.edu.cn>,
	Massimo Cetra <ctrix+debianbugs@navynet.it>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51699 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885Ab2GJIlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 04:41:39 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1207071322490.5927@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 07, 2012 at 01:27:49PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 7 Jul 2012, Lin Ming wrote:
> 
> > On Sat, 2012-07-07 at 12:48 +0300, Julian Anastasov wrote:
> > > 
> > > 	Very good. Thanks for tracking and fixing this bug.
> > > Can you send a copy to Simon Horman <horms@verge.net.au>
> > > with correct Subject. As this change can go to stable
> > > kernels you can also improve the comments, for example:
> > > 
> > > ipvs: fix oops on NAT reply in br_nf context
> > > 
> > > 	IPVS should not reset skb->nf_bridge in FORWARD hook
> > > by calling nf_reset for NAT replies. It triggers oops in
> > > br_nf_forward_finish.
> > > 
> > > [here follows your corrected description including
> > > the stack trace]
> > 
> > How about below? Can I have your ACK?
> > I'll resend this patch in another mail.
> 
> 	Very good. You can add my
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, I will queue this up in my ipvs tree and see
about getting it included in 3.5

It seems to me that this problem has been present since 2.6.37
and thus is stable material.
