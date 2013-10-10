From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: allow to setup multicast address for veth device
Date: Thu, 10 Oct 2013 00:16:00 -0400 (EDT)
Message-ID: <20131010.001600.2134679085429611353.davem@davemloft.net>
References: <1380876744-606-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, edumazet@google.com,
	kaber@trash.net, hannes@stressinduktion.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125Ab3JJEQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 00:16:02 -0400
In-Reply-To: <1380876744-606-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Fri, 4 Oct 2013 16:52:24 +0800

> We can only setup multicast address for network device when
> net_device_ops->ndo_set_rx_mode is not null.
> 
> Some configurations need to add multicast address for net
> device, such as netfilter cluster match module.
> 
> Add a fake ndo_set_rx_mode function to allow this operation.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied, thanks.
