From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/2] r6040: disable pci device if the subsequent
 calls (after pci_enable_device) fails
Date: Tue, 29 May 2012 22:31:30 -0400 (EDT)
Message-ID: <20120529.223130.1732658596355230297.davem@davemloft.net>
References: <1338334722-14730-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: devendra.aaru@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338334722-14730-1-git-send-email-devendra.aaru@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Devendra Naga <devendra.aaru@gmail.com>
Date: Wed, 30 May 2012 05:08:42 +0530

> the calls after the pci_enable_device may fail, and will error out with out
> disabling it. disable the device at error paths.
> 
> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>

Applied.
