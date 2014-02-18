From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/35] net: Use pci_enable_msix_range()
 instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 15:34:34 -0500 (EST)
Message-ID: <20140218.153434.1953797715072458396.davem@davemloft.net>
References: <cover.1392717502.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com,
	linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, pv-drivers@vmware.com,
	wil6210@qca.qualcomm.com
To: agordeev@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392717502.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Gordeev <agordeev@redhat.com>
Date: Tue, 18 Feb 2014 11:07:52 +0100

> As result of deprecation of MSI-X/MSI enablement functions
> pci_enable_msix() and pci_enable_msi_block() all drivers
> using these two interfaces need to be updated to use the
> new pci_enable_msi_range() and pci_enable_msix_range()
> interfaces.
> 
> Cc: e1000-devel@lists.sourceforge.net
> Cc: linux-driver@qlogic.com
> Cc: linux-net-drivers@solarflare.com
> Cc: linux-pci@vger.kernel.org
> Cc: linux-rdma@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: pv-drivers@vmware.com
> Cc: wil6210@qca.qualcomm.com

Series applied, thanks.
