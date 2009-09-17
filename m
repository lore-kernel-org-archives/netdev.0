From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next]atl1e:fix 2.6.31-git4 -- ATL1E 0000:03:00.0:
 DMA-API: device driver frees DMA
Date: Thu, 17 Sep 2009 10:27:35 -0700 (PDT)
Message-ID: <20090917.102735.33788478.davem@davemloft.net>
References: <12530933101782-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miles.lane@gmail.com, chris.snook@gmail.com, jcliburn@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755492AbZIQR1U@vger.kernel.org>
In-Reply-To: <12530933101782-git-send-email-jie.yang@atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <jie.yang@atheros.com>
Date: Wed, 16 Sep 2009 17:28:30 +0800

> use the wrong API when free dma. So when map dma use a flag to demostrate whether it is 'pci_map_single' or 'pci_map_page'. When free the dma, check the flags to select the right APIs('pci_unmap_single' or 'pci_unmap_page').
> 
> set the flags type to u16  instead of unsigned long  on David's comments.
> 
> Signed-off-by: Jie Yang <jie.yang@atheros.com>

Applied.
