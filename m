From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: stmmac: Fix incorrect memcpy source memory
Date: Wed, 25 May 2016 20:20:20 -0400 (EDT)
Message-ID: <20160525.202020.79406085719609678.davem@redhat.com>
References: <1464216023-6428-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, andrew@lunn.ch
To: marex@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34411 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751790AbcEZAUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2016 20:20:24 -0400
In-Reply-To: <1464216023-6428-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Vasut <marex@denx.de>
Date: Thu, 26 May 2016 00:40:23 +0200

> The memcpy() currently copies mdio_bus_data into new_bus->irq, which
> makes no sense, since the mdio_bus_data structure contains more than
> just irqs. The code was likely supposed to copy mdio_bus_data->irqs
> into the new_bus->irq instead, so fix this.
> 
> Signed-off-by: Marek Vasut <marex@denx.de>

Fixes: e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")

Andrew, please review.
