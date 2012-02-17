From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 03/10] davinci_emac: use eth_hw_addr_random()
 instead of random_ether_addr()
Date: Fri, 17 Feb 2012 16:00:16 -0500 (EST)
Message-ID: <20120217.160016.2282514497251202216.davem@davemloft.net>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
	<1329493411-25750-4-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dkukawka@suse.de, richard.cochran@omicron.at, julia@diku.dk,
	s.hauer@pengutronix.de, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-4-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Fri, 17 Feb 2012 16:43:24 +0100

> Use eth_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.
> 
> Reset the state to NET_ADDR_PERM as soon as the MAC get
> changed via .ndo_set_mac_address.
> 
> Remove one memcpy from emac_dev_setmac_addr() since this is a
> duplicate: it's already done some lines above.
> 
> v2: use bitops, adapt to eth_hw_addr_random, remove a memcpy
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied.
