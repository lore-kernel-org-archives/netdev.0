From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 10/12] [IPv6]: Use rtnl registration interface
Date: Wed, 21 Mar 2007 02:01:37 +0100 (CET)
Message-ID: <20070321.020137.109232015.yoshfuji@linux-ipv6.org>
References: <20070321000553.070942307@lsx.localdomain>
	<20070321000710.549330036@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35093 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933541AbXCUBA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 21:00:59 -0400
In-Reply-To: <20070321000710.549330036@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070321000710.549330036@lsx.localdomain> (at Wed, 21 Mar 2007 01:06:03 +0100), Thomas Graf <tgraf@suug.ch> says:

> -static int
> -inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
> +static int nl_addr_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
>  {
>  	struct ifaddrmsg *ifm;

I'm rather not favor changing function names here...

--yoshfuji
