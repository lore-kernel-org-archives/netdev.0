From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 18/34] ipvs: prevent mixing heterogeneous pools and
 synchronization
Date: Tue, 30 Sep 2014 11:21:44 +0900
Message-ID: <20140930022144.GH10373@verge.net.au>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
 <1411994363-8451-19-git-send-email-pablo@netfilter.org>
 <54298616.7080307@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55776 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172AbaI3CVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 22:21:47 -0400
Content-Disposition: inline
In-Reply-To: <54298616.7080307@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 08:17:26PM +0400, Sergei Shtylyov wrote:
> On 09/29/2014 04:39 PM, Pablo Neira Ayuso wrote:
> 
> >From: Alex Gartrell <agartrell@fb.com>
> 
> >The synchronization protocol is not compatible with heterogeneous pools, so
> >we need to verify that we're not turning both on at the same time.
> 
> >Signed-off-by: Alex Gartrell <agartrell@fb.com>
> >Acked-by: Julian Anastasov <ja@ssi.bg>
> >Signed-off-by: Simon Horman <horms@verge.net.au>
> >---
> >  include/net/ip_vs.h            |    4 ++++
> >  net/netfilter/ipvs/ip_vs_ctl.c |   15 +++++++++++++++
> >  2 files changed, 19 insertions(+)
> 
> >diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> >index 7600dbe..576d7f0 100644
> >--- a/include/net/ip_vs.h
> >+++ b/include/net/ip_vs.h
> >@@ -990,6 +990,10 @@ struct netns_ipvs {
> >  	char			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
> >  	/* net name space ptr */
> >  	struct net		*net;            /* Needed by timer routines */
> >+	/* Number of heterogeneous destinations, needed because
> >+	 * heterogeneous are not supported when synchronization is
> >+	 * enabled */
> 
>    Multi-line comment style in the networking code is:
> 
> /* bla
>  * bla
>  */

Thanks, I have sent a cleanup patch.
