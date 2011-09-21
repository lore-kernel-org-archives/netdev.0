From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tg3: fix VLAN tagging regression
Date: Wed, 21 Sep 2011 02:15:51 -0400 (EDT)
Message-ID: <20110921.021551.1015460502805882165.davem@davemloft.net>
References: <4E78FC38.7040903@kasperkp.dk>
	<4E79168D.4080201@kasperkp.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel@kasperkp.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331Ab1IUGRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 02:17:04 -0400
In-Reply-To: <4E79168D.4080201@kasperkp.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kasper Pedersen <kernel@kasperkp.dk>
Date: Wed, 21 Sep 2011 00:41:17 +0200

> commit 92cd3a17ce9c719abb4c28dee3438e0c641f8de4
>     tg3: Simplify tx bd assignments
> 
> broke VLAN tagging on outbound packets.
> It ifdef'ed BCM_KERNEL_SUPPORTS_8021Q, but this
> is not set anywhere. So vlan never gets set, and
> all packets are sent with vlan=0.
> 
> v2: We can just remove the test. vlan_tx_tag_present
> is valid regardless of whether the 802.1q module
> is built.
> 
> Tested on BCM5721 rev 11.
> 
> Signed-off-by: Kasper Pedersen <kernel@kasperkp.dk>

Applied.
