From: Amir Vadai <avadai@redhat.com>
Subject: Re: mlx4: Use pci_enable_msix_range()
Date: Sun, 2 Feb 2014 11:43:34 +0200
Message-ID: <20140202094334.GE24400@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <cover.1391172839.git.agordeev@redhat.com>
 <2f6674dabb90d4cbca3ef4039c3b893f2e5e9ec4.1391172839.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2f6674dabb90d4cbca3ef4039c3b893f2e5e9ec4.1391172839.git.agordeev@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31/01/14 16:08 +0100, Alexander Gordeev wrote:
> As result of deprecation of MSI-X/MSI enablement functions
> pci_enable_msix() and pci_enable_msi_block() all drivers
> using these two interfaces need to be updated to use the
> new pci_enable_msi_range() and pci_enable_msix_range()
> interfaces.
> 
> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c |   19 ++++---------------
>  1 files changed, 4 insertions(+), 15 deletions(-)
> 

Acked By: Amir Vadai <amirv@mellanox.com>
