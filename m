From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next v5 8/8] 6lowpan: handling 6lowpan
 fragmentation via inet_frag api
Date: Thu, 27 Feb 2014 15:56:39 -0500 (EST)
Message-ID: <20140227.155639.1203195193096437286.davem@redhat.com>
References: <1393488382-1250-1-git-send-email-alex.aring@gmail.com>
	<1393488382-1250-9-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23709 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067AbaB0U4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 15:56:51 -0500
In-Reply-To: <1393488382-1250-9-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Thu, 27 Feb 2014 09:06:22 +0100

> +static int lowpan_frag_queue(struct lowpan_frag_queue *fq,
> +			     struct sk_buff *skb, const u8 frag_type,
> +			     const struct ieee802154_frag_info *frag_info)

The 'frag_info' argument is unused.  You always explicitly access
mac_cb()->frag_info here.
