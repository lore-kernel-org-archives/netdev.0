From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/1] lvs: Use IS_ERR_OR_NULL(svc) instead of IS_ERR(svc)
 || svc == NULL
Date: Fri, 22 Jul 2016 17:11:43 +0900
Message-ID: <20160722081143.GB29153@verge.net.au>
References: <1469145341-15488-1-git-send-email-fgao@ikuai8.com>
 <alpine.LFD.2.11.1607220757100.1764@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao Feng <fgao@ikuai8.com.aqb.so>, wensong@linux-vs.org,
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	gfree.wind@gmail.com
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43005 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbcGVILs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 04:11:48 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1607220757100.1764@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 22, 2016 at 08:04:50AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 22 Jul 2016, fgao@ikuai8.com.aqb.so wrote:
> 
> > From: Gao Feng <fgao@ikuai8.com>
> > 
> > This minor refactoring does not change the logic of function
> > ip_vs_genl_dump_dests.
> > 
> > Signed-off-by: Gao Feng <fgao@ikuai8.com>
> 
> 	Looks good to me,
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	If there is a next version you can change above
> "lvs" with "ipvs" in the Subject, this is the name we use
> for the kernel part.

No need to repost just to fix that,
I can fix it up when queuing up the patch.

> 
> > ---
> >  v1: Initial patch
> > 
> >  net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > index c3c809b..6dc86cc 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > @@ -3267,7 +3267,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
> >  
> >  
> >  	svc = ip_vs_genl_find_service(ipvs, attrs[IPVS_CMD_ATTR_SERVICE]);
> > -	if (IS_ERR(svc) || svc == NULL)
> > +	if (IS_ERR_OR_NULL(svc))
> >  		goto out_err;
> >  
> >  	/* Dump the destinations */
> > -- 
> > 1.9.1
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
