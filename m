From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: propagate NETIF_F_HIGHDMA to vlans
Date: Sun, 26 Sep 2010 18:27:28 -0700 (PDT)
Message-ID: <20100926.182728.245387828.davem@davemloft.net>
References: <AANLkTikDdxFho2ioBHMbze685+garDWF9kF3qFXZA9Hr@mail.gmail.com>
	<1285222405.2380.80.camel@edumazet-laptop>
	<1285238771.2864.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, yi.zou@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44524
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758588Ab0I0B1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 21:27:08 -0400
In-Reply-To: <1285238771.2864.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Sep 2010 12:46:11 +0200

> Automatically allows vlans to get NETIF_F_HIGHDMA if underlying device
> supports it.
> 
> On 32bit arches (and more precisely if CONFIG_HIGHMEM is enabled), it
> can help to reduce cost of illegal_highdma() and __skb_linearize()
> calls.
> 
> Tested on tg3 , bnx2, bonding, this worked very well.
> 
> This is a generalization of a patch provided by Yi Zou & Jeff Kirsher.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
