From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] openvswitch: adjust skb_gso_segment() for rx
 path
Date: Thu, 31 Jan 2013 16:31:16 +0800
Message-ID: <1359621076.2814.0.camel@cr0>
References: <1359535089-18348-1-git-send-email-amwang@redhat.com>
	 <20130130.224629.25122487947508141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40578 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753496Ab3AaIbb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 03:31:31 -0500
In-Reply-To: <20130130.224629.25122487947508141.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-30 at 22:46 -0500, David Miller wrote:
> 
> Instead of having the crazy test, make the caller
> tell the context, TX or RX.
> 
> struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
> 				  netdev_features_t features,
> 				  bool tx_path);
> 
> static inline struct sk_buff *
> skb_gso_segment(struct sk_buff *skb, netdev_features_t features)
> {
> 	__skb_gso_segment(skb, features, true);
> }

Yeah, good idea! Will do.
