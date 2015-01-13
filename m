From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 1/2] net: sched: fix skb->protocol use in
 case of accelerated vlan path
Date: Tue, 13 Jan 2015 17:51:21 -0500 (EST)
Message-ID: <20150113.175121.383052764979199992.davem@davemloft.net>
References: <1421165624-19882-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, kaber@trash.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbbAMWvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 17:51:25 -0500
In-Reply-To: <1421165624-19882-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 13 Jan 2015 17:13:43 +0100

> tc code implicitly considers skb->protocol even in case of accelerated
> vlan paths and expects vlan protocol type here. However, on rx path,
> if the vlan header was already stripped, skb->protocol contains value
> of next header. Similar situation is on tx path.
> 
> So for skbs that use skb->vlan_tci for tagging, use skb->vlan_proto instead.
> 
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
