From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 04/10] xilinx ll_temac: use eth_hw_addr_random()
 instead of random_ether_addr()
Date: Fri, 17 Feb 2012 16:00:56 -0500 (EST)
Message-ID: <20120217.160056.468165222350582907.davem@davemloft.net>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
	<1329493411-25750-5-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dkukawka@suse.de, sfr@canb.auug.org.au, ricardo.ribalda@gmail.com,
	thomas@m3y3r.de, richard.cochran@omicron.at,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-5-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Fri, 17 Feb 2012 16:43:25 +0100

> Use eth_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.
> 
> Reset the state to NET_ADDR_PERM as soon as the MAC get
> changed via .ndo_set_mac_address.
> 
> v2: reworked to prevent using an extra variable
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied, but:

> +	else 

Trailing whitespace.  This isn't something you need to be a rocket
scientist to catch, the tools find it for you, as they did for me.
