From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: Fix MSI-X initialization code
Date: Tue, 15 Apr 2014 15:15:20 -0400 (EDT)
Message-ID: <20140415.151520.1523135090870130956.davem@davemloft.net>
References: <1397554634-26795-1-git-send-email-agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shahed.shaikh@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: agordeev@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397554634-26795-1-git-send-email-agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Gordeev <agordeev@redhat.com>
Date: Tue, 15 Apr 2014 11:37:14 +0200

> Function qlcnic_setup_tss_rss_intr() might enter endless
> loop in case pci_enable_msix() contiguously returns a
> positive number of MSI-Xs that could have been allocated.
> Besides, the function contains 'err = -EIO;' assignment
> that never could be reached. This update fixes the
> aforementioned issues.
> 
> Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Cc: Dept-HSGLinuxNICDev@qlogic.com
> Cc: netdev@vger.kernel.org
> Cc: linux-pci@vger.kernel.org
> 
> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>

Applied, thanks.
