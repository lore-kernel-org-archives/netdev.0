From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IFGROUPv4 3/3] Netfilter Interface group match
Date: Thu, 25 Oct 2007 17:18:51 +0200
Message-ID: <4720B3DB.7010106@trash.net>
References: <11933245923082-git-send-email-panther@balabit.hu> <11933245922165-git-send-email-panther@balabit.hu> <11933245921874-git-send-email-panther@balabit.hu> <11933245931626-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44427 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755398AbXJYPUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 11:20:16 -0400
In-Reply-To: <11933245931626-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> +++ b/net/netfilter/xt_ifgroup.c
> +static bool
> +ifgroup_match(const struct sk_buff *skb,
> +	     const struct net_device *in,
> +	     const struct net_device *out,
> +	     const struct xt_match *match,
> +	     const void *matchinfo,
> +	     int offset,
> +	     unsigned int protoff,
> +	     bool *hotdrop)
> +{
> +	const struct xt_ifgroup_info *info = matchinfo;
> +	
> +	if (info->flags & XT_IFGROUP_MATCH_IN &&  !ifgroup_match_in(in, info))
> +		return false;
> +	if (info->flags & XT_IFGROUP_MATCH_OUT &&  !ifgroup_match_out(out, info))


If you'd remove the extra space it would fit on a 80 character line.
