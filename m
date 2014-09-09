From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs] Added simple weighted failover scheduler to ipvs
Date: Tue, 9 Sep 2014 08:57:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1409090834190.2676@ja.home.ssi.bg>
References: <20140908210804.GA9236@kmathis.internal.monetra.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>
To: Kenny Mathis <kmathis@chokepoint.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55971 "EHLO localhost.localdomain"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755661AbaIIF6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 01:58:13 -0400
In-Reply-To: <20140908210804.GA9236@kmathis.internal.monetra.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 8 Sep 2014, Kenny Mathis wrote:

> Please consider this patch for addition in 3.17
> 
> Creates net/netfilter/ipvs/ip_vs_fo.c

	Lines like the two above usually go after
the '---' line. New features go first to the
{ipvs,nf,net}-next trees.

> Added simple weighted IPVS failover support to the Linux kernel.  All
> other scheduling modules implement some form of load balancing, while 
> this offers a simple failover solution.  Connections are directed to the
> appropriate server based solely on highest weight value and server
> availability.  Tested functionality with keepalived.

	What about changing 'Added' with 'Add', using
'ipvs: Add simple ...' in Subject line and reducing the
many spaces in above comments to one? The main thing,
there must be a Signed-off-by: line:

# scripts/checkpatch.pl --strict /tmp/fo.diff 
ERROR: Missing Signed-off-by: line(s)

total: 1 errors, 0 warnings, 0 checks, 102 lines checked

/tmp/fo.diff has style problems, please review.

> +static struct ip_vs_dest *
> +ip_vs_fo_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> +		  struct ip_vs_iphdr *iph)
> +{
> +	struct ip_vs_dest *dest = NULL, *hweight = NULL;

	' = NULL' after dest is not needed. Otherwise,
the module looks correctly implemented. You can post
PATCHv2 after making all needed changes.

Regards

--
Julian Anastasov <ja@ssi.bg>
