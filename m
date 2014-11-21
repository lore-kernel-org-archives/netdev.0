From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] packet: make packet_snd fail on len
 smaller than l2 header
Date: Fri, 21 Nov 2014 14:43:54 -0500 (EST)
Message-ID: <20141121.144354.321574305151092990.davem@davemloft.net>
References: <1416420616-5029-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, dborkman@redhat.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbaKUTn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 14:43:58 -0500
In-Reply-To: <1416420616-5029-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 19 Nov 2014 13:10:16 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> When sending packets out with PF_PACKET, SOCK_RAW, ensure that the
> packet is at least as long as the device's expected link layer header.
> This check already exists in tpacket_snd, but not in packet_snd.
> Also rate limit the warning in tpacket_snd.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks.
