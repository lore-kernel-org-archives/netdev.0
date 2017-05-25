From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/6] net: mpls: minor cleanups
Date: Thu, 25 May 2017 14:56:31 -0400 (EDT)
Message-ID: <20170525.145631.1427287907712541949.davem@davemloft.net>
References: <20170525035442.51407-1-dsahern@gmail.com>
        <20170525035442.51407-7-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60556 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936824AbdEYS4c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 14:56:32 -0400
In-Reply-To: <20170525035442.51407-7-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed, 24 May 2017 21:54:42 -0600

> Noticed these doing the extack support:
> - nla_get_via is only used in af_mpls.c so remove from internal.h
 ...
> @@ -43,6 +43,9 @@ static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
>  		       struct nlmsghdr *nlh, struct net *net, u32 portid,
>  		       unsigned int nlm_flags);
>  
> +static int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
> +		       u8 via[], struct netlink_ext_ack *extack);
> +
>  static struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
>  {
>  	struct mpls_route *rt = NULL;

David, please mark the actual defintion static as well.

I'm surprised the compiler accepts this, but it does :-)
