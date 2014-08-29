From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next v3 2/2] xfrm: configure policy hash table
 thresholds by netlink
Date: Fri, 29 Aug 2014 11:54:31 +0200
Message-ID: <20140829095431.GF6390@secunet.com>
References: <20140821060944.GC6390@secunet.com>
 <1409154495-1343-1-git-send-email-christophe.gouault@6wind.com>
 <1409154495-1343-3-git-send-email-christophe.gouault@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50576 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611AbaH2Jyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:54:43 -0400
Content-Disposition: inline
In-Reply-To: <1409154495-1343-3-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2014 at 05:48:15PM +0200, Christophe Gouault wrote:
>  
> +static int xfrm_set_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
> +			    struct nlattr **attrs)
> +{
> +	struct net *net = sock_net(skb->sk);
> +	u32 *flags = nlmsg_data(nlh);
> +	u32 sportid = NETLINK_CB(skb).portid;
> +	u32 seq = nlh->nlmsg_seq;

flags, sportid and seq are unused now. Please remove them.
