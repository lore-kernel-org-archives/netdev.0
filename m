From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Add module parameter for passing the MAC address
Date: Wed, 05 Aug 2015 17:32:33 -0700 (PDT)
Message-ID: <20150805.173233.539752020022715092.davem@davemloft.net>
References: <1438789854-29194-1-git-send-email-Liviu.Dudau@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlindner@marvell.com, stephen@networkplumber.org,
	ryan.harkin@linaro.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Liviu.Dudau@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438789854-29194-1-git-send-email-Liviu.Dudau@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liviu Dudau <Liviu.Dudau@arm.com>
Date: Wed,  5 Aug 2015 16:50:54 +0100

> For designs where EEPROMs are not connected to PCI Yukon2
> chips we need to get the MAC address from the firmware.
> Add a module parameter called 'mac_address' for this. It
> will be used if no DT node can be found and the B2_MAC
> register holds an invalid value.
> 
> Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>

Sorry, such module options are absolutely not allowed.

If an invalid MAC is present, it should be set to a random
one via eth_random_addr().
