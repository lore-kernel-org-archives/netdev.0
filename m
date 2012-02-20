From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] adi: adapt to eth_hw_addr_random() and changes
 in arch/blackfin
Date: Sun, 19 Feb 2012 19:05:36 -0500 (EST)
Message-ID: <20120219.190536.1601398467747959636.davem@davemloft.net>
References: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de>
	<1329412171-20704-3-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dkukawka@suse.de, vapier@gentoo.org, sonic.zhang@analog.com,
	jeffrey.t.kirsher@intel.com, bob.liu@analog.com,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329412171-20704-3-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Thu, 16 Feb 2012 18:09:31 +0100

> Adapt adi ethernet driver to changes in bfin_get_ether_addr()
> from arch/blackfin. bfin_get_ether_addr() returns now a state.
> Set a random mac address via new eth_hw_addr_random() in case
> the return value is not 0.
> 
> Reset the state to NET_ADDR_PERM as soon as the MAC get
> changed via .ndo_set_mac_address.
> 
> v2: change the logic to reduce unneeded checks
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied.
