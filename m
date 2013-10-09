From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: allow to setup multicast address for veth device
Date: Wed, 09 Oct 2013 13:22:57 -0400 (EDT)
Message-ID: <20131009.132257.575792692083710085.davem@davemloft.net>
References: <1380876744-606-1-git-send-email-gaofeng@cn.fujitsu.com>
	<52551ABD.40603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, edumazet@google.com,
	kaber@trash.net, hannes@stressinduktion.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059Ab3JIRW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 13:22:59 -0400
In-Reply-To: <52551ABD.40603@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Wed, 09 Oct 2013 16:58:37 +0800

> Hi David,
> 
> On 10/04/2013 04:52 PM, Gao feng wrote:
>> We can only setup multicast address for network device when
>> net_device_ops->ndo_set_rx_mode is not null.
>> 
>> Some configurations need to add multicast address for net
>> device, such as netfilter cluster match module.
>> 
>> Add a fake ndo_set_rx_mode function to allow this operation.
>> 
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> 
> I see this patch being marked as "Changes Requested" on patchwork.
> Is there something I missed?

It was a mistake, I put it back in Under Review.
