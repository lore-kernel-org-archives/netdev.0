From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r6040: disable pci device if the subsequent calls
 (after pci_enable_device) fails
Date: Tue, 29 May 2012 17:28:43 -0400 (EDT)
Message-ID: <20120529.172843.1775456038320356018.davem@davemloft.net>
References: <1338206223-26781-1-git-send-email-devendra.aaru@gmail.com>
	<1659482.3g1Zl6FDuM@flexo>
	<20120529.172229.277102319861990758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devendra.aaru@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: florian@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120529.172229.277102319861990758.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 29 May 2012 17:22:29 -0400 (EDT)

> From: Florian Fainelli <florian@openwrt.org>
> Date: Tue, 29 May 2012 11:20:50 +0200
> 
>> On Monday 28 May 2012 17:27:03 Devendra Naga wrote:
>>> the calls after the pci_enable_device may fail, and will error out with out
>>> disabling it. disable the device at error paths.
>> 
>> Looks good, thanks Devendra!
>> 
>>> 
>>> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
>> 
>> Acked-by: Florian Fainelli <florian@openwrt.org>
> 
> Applied.

Actually, reverted, you didn't test this patch at all.

You didn't even look at the warnings emitted by the compiler
with your changes installed.

You're passing a network device pointer into the PCI device
disable routine, which takes a PCI device pointer.

I can't express to you how extremely irritating it is when
people submit patches like this.

The bug in question is 1,000 times less harmful than your fix.
