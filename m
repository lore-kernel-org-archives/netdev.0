From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] vlan: mask vlan prio bits
Date: Wed, 17 Jul 2013 17:58:23 -0700 (PDT)
Message-ID: <20130717.175823.1205139202025326865.davem@davemloft.net>
References: <1374083074.6097.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, florz@florz.de, sesse@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757972Ab3GRA60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 20:58:26 -0400
In-Reply-To: <1374083074.6097.18.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Jul 2013 10:44:34 -0700

> Should we clear skb->vlan_tci in iptunnel_xmit(), or should we clear it
> in __netif_receive_skb_core() like in this patch ?

The safest thing to do is as early as possible, so yes your patch here
doing it in __netif_receive_skb_core() looks good to me.
