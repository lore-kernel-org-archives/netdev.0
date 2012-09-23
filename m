From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 1/2] netlink: kill netlink_set_nonroot
Date: Sun, 23 Sep 2012 07:00:42 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1209230700120.2498@nerf07.vanv.qr>
References: <1346934712-3056-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:38202 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505Ab2IWFAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2012 01:00:45 -0400
In-Reply-To: <1346934712-3056-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2012-09-06 14:31, pablo@netfilter.org wrote:

> /* optional Netlink kernel configuration parameters */
> struct netlink_kernel_cfg {
> 	unsigned int	groups;
> 	void		(*input)(struct sk_buff *skb);
> 	struct mutex	*cb_mutex;
> 	void		(*bind)(int group);
>+	unsigned int	flags;
> };

Putting flags next to groups would reduce the hole there.
