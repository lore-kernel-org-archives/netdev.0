From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 01/10] au1000_eth: use eth_hw_addr_random() instead
 of random_ether_addr()
Date: Fri, 17 Feb 2012 15:59:30 -0500 (EST)
Message-ID: <20120217.155930.1401463574783963868.davem@davemloft.net>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
	<1329493411-25750-2-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dkukawka@suse.de, jeffrey.t.kirsher@intel.com, jpirko@redhat.com,
	mcuos.com@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-2-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Fri, 17 Feb 2012 16:43:22 +0100

> Use eth_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.
> 
> v2: adapt to eth_hw_addr_random()
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Please don't shit up the comments:

> -	/* set a random MAC now in case platform_data doesn't provide one */
 ...
> +			/*set a random MAC since no valid provided by platform_data*/

You had to work to make that comment look worse than it originally
did in the code, spaces around the sentence and if you can be so
bothered capitalize sentences and put proper punctionation at the
end.

I took care of this, but I will not next time.
