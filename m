From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 09/10] atheros eth: set addr_assign_type if
 random_ether_addr() used
Date: Fri, 17 Feb 2012 16:02:54 -0500 (EST)
Message-ID: <20120217.160254.571979413222649775.davem@davemloft.net>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
	<1329493411-25750-10-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, dkukawka@suse.de, chris.snook@gmail.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-10-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Fri, 17 Feb 2012 16:43:30 +0100

> Set addr_assign_type correctly to NET_ADDR_RANDOM in case
> a random MAC address was generated and assigned to the netdevice.
> 
> Fix error handling in atl1c_probe(). If atl1c_read_mac_addr()
> couldn't get the hw mac address, and a random mac address get
> set return the error code. Don't go to err_eeprom in
> atl1c_probe(), use the generated MAC address in this case.
> 
> Reset the state to NET_ADDR_PERM as soon as the MAC get
> changed via .ndo_set_mac_address.
> 
> v2: use bitops
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied.
