From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] cisco/enic: use eth_hw_addr_random() instead of
 random_ether_addr()
Date: Sat, 18 Feb 2012 01:50:59 -0500 (EST)
Message-ID: <20120218.015059.195369430178043130.davem@davemloft.net>
References: <1329516810-26175-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, dkukawka@suse.de, roprabhu@cisco.com,
	dwang2@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329516810-26175-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Fri, 17 Feb 2012 23:13:30 +0100

> Use dev_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.
> 
> Reset the state to NET_ADDR_PERM as soon as the MAC get
> changed via .ndo_set_mac_address.
> 
> v3: adapt to net-next
> v2: use bitops, adapt to eth_hw_addr_random(), add a comment
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied, thanks.
