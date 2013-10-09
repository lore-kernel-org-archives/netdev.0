From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] veth: allow to setup multicast address for veth device
Date: Wed, 09 Oct 2013 16:58:37 +0800
Message-ID: <52551ABD.40603@cn.fujitsu.com>
References: <1380876744-606-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Gao feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org,
	pablo@netfilter.org, edumazet@google.com, kaber@trash.net,
	hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:30336 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752793Ab3JII5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Oct 2013 04:57:31 -0400
In-Reply-To: <1380876744-606-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 10/04/2013 04:52 PM, Gao feng wrote:
> We can only setup multicast address for network device when
> net_device_ops->ndo_set_rx_mode is not null.
> 
> Some configurations need to add multicast address for net
> device, such as netfilter cluster match module.
> 
> Add a fake ndo_set_rx_mode function to allow this operation.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

I see this patch being marked as "Changes Requested" on patchwork.
Is there something I missed?
