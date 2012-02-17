From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/10] lantiq_etop: set addr_assign_type if
 random_ether_addr() used
Date: Fri, 17 Feb 2012 16:00:06 -0500 (EST)
Message-ID: <20120217.160006.1000847808550095794.davem@davemloft.net>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
	<1329493411-25750-3-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dkukawka@suse.de, blogic@openwrt.org, ralf@linux-mips.org,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-3-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Fri, 17 Feb 2012 16:43:23 +0100

> Set addr_assign_type correctly to NET_ADDR_RANDOM in case
> a random MAC address was generated and assigned to the netdevice.
> 
> v2: added comment, renamed bool variable to random_mac
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

More bad comment formatting.

> +	/*set addr_assign_type here, ltq_etop_set_mac_address would reset it*/

Again, I fixed it up but I will not next time.
