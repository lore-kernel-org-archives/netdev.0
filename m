From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: fix building without CONFIG_PCI_MSI
Date: Thu, 13 Mar 2014 12:57:10 -0400 (EDT)
Message-ID: <20140313.125710.1893798649203550983.davem@davemloft.net>
References: <7825453.7LB7BmvA2b@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, sbhatewara@vmware.com,
	pv-drivers@vmware.com, stable@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7825453.7LB7BmvA2b@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 13 Mar 2014 10:44:34 +0100

> Since commit d25f06ea466e "vmxnet3: fix netpoll race condition",
> the vmxnet3 driver fails to build when CONFIG_PCI_MSI is disabled,
> because it unconditionally references the vmxnet3_msix_rx()
> function.
> 
> To fix this, use the same #ifdef in the caller that exists around
> the function definition.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Shreyas Bhatewara <sbhatewara@vmware.com>
> Cc: "VMware, Inc." <pv-drivers@vmware.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: stable@vger.kernel.org
> ---
> Found this during randconfig testing on ARM. Most of the time when
> I report network driver problems, they get fixed in the netdev tree
> before I even find them, but since this is for a patch marked "stable",
> I made a proper patch anyway.
> 
> Please ignore if this is already a known problem, otherwise make sure
> the original patch doesn't get backported without addressing this
> issue first.

Applied, and queued up for -stable, thanks.
