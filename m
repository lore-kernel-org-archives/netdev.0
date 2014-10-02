From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] udp: Generalize GSO for UDP tunnels
Date: Wed, 01 Oct 2014 21:36:24 -0400 (EDT)
Message-ID: <20141001.213624.146270186000828895.davem@davemloft.net>
References: <1412047353-28502-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbaJBBg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 21:36:26 -0400
In-Reply-To: <1412047353-28502-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 29 Sep 2014 20:22:28 -0700

> This patch set generalizes the UDP tunnel segmentation functions so
> that they can work with various protocol encapsulations. The primary
> change is to set the inner_protocol field in the skbuff when creating
> the encapsulated packet, and then in skb_udp_tunnel_segment this data
> is used to determine the function for segmenting the encapsulated
> packet. The inner_protocol field is overloaded to take either an
> Ethertype or IP protocol.
> 
> The inner_protocol is set on transmit using skb_set_inner_ipproto or
> skb_set_inner_protocol functions. VXLAN and IP tunnels (for fou GSO)
> were modified to call these.

Series applied, thanks Tom.
