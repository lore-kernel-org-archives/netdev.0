From: David Miller <davem@davemloft.net>
Subject: Re: ixgbevf: Use pci_enable_msix_range() instead of
 pci_enable_msix()
Date: Tue, 18 Feb 2014 15:56:32 -0500 (EST)
Message-ID: <20140218.155632.1364973664624371603.davem@davemloft.net>
References: <cover.1392717502.git.agordeev@redhat.com>
	<9ee830cfd4b417f230f77dd37256ca8e4396ecbe.1392717503.git.agordeev@redhat.com>
	<20140218120136.GA8770@mtl-eit-vdi-22.mtl.labs.mlnx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agordeev@redhat.com, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: amirv@mellanox.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20140218120136.GA8770@mtl-eit-vdi-22.mtl.labs.mlnx>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 18 Feb 2014 14:01:38 +0200

> On 18/02/14 11:11 +0100, Alexander Gordeev wrote:
>> As result of deprecation of MSI-X/MSI enablement functions
>> pci_enable_msix() and pci_enable_msi_block() all drivers
>> using these two interfaces need to be updated to use the
>> new pci_enable_msi_range() and pci_enable_msix_range()
>> interfaces.
>> 
>> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Cc: Bruce Allan <bruce.w.allan@intel.com>
>> Cc: e1000-devel@lists.sourceforge.net
>> Cc: netdev@vger.kernel.org
>> Cc: linux-pci@vger.kernel.org
>> ---
> 
> Acked-By: Amir Vadai <amirv@mellanox.com>

Since you obviously didn't intend to ACK this, I removed this ACK when
I committed the series.
