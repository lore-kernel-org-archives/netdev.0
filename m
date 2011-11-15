From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v4 2/8] forcedeth: Add messages to indicate
 using MSI or MSI-X
Date: Tue, 15 Nov 2011 11:32:03 -0800
Message-ID: <1321385523.21286.12.camel@Joe-Laptop>
References: <cover.1321384662.git.david.decotigny@google.com>
	 <97a5a50baaca7b272dfb7a1a06e88df4888f12b9.1321384662.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	Mike Ditto <mditto@google.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <97a5a50baaca7b272dfb7a1a06e88df4888f12b9.1321384662.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-11-15 at 11:25 -0800, David Decotigny wrote:
> From: Mike Ditto <mditto@google.com>
> 
> This adds a few debug messages to indicate whether PCIe interrupts are
> signaled with MSI or MSI-X.

Perhaps the changelog would be better without "debug".
These added messages aren't really debug messages.
They are emitted as netdev_info vs netdev_dbg.

> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
[]
> @@ -3810,6 +3810,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
> +			netdev_info(dev, "MSI-X enabled\n");
> @@ -3831,6 +3832,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
> +			netdev_info(dev, "MSI enabled\n");
