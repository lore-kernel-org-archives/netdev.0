From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] udp: Generalize GSO for UDP tunnels
Date: Mon, 29 Sep 2014 16:43:06 -0400 (EDT)
Message-ID: <20140929.164306.1423529448299226409.davem@davemloft.net>
References: <1411748554-7346-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbaI2UnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:43:09 -0400
In-Reply-To: <1411748554-7346-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 26 Sep 2014 09:22:29 -0700

> This patch set generalizes the UDP tunnel segmentation functions so
> that they can work with various protocol encapsulations. The primary
> change is to set the inner_protocol field in the skbuff when creating
> the encapsulated packet, and then in skb_udp_tunnel_segment this data
> is used to determine the function for segmenting the encapsulated
> packet. The inner_protocol field is overloaded to take either an
> Ethertype or IP protocol.

Tom, this series needs to be respun due to Eric Dumazet's sk_buff flags
rework in net-next.

Thanks.
