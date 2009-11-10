From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] ixgbe: r_idx not used in
	ixgbe_msix_clean_rx()
Date: Tue, 10 Nov 2009 08:45:14 -0800
Message-ID: <1257871514.3007.23.camel@ppwaskie-mobl2>
References: <20091110164006.GB816@lilem.mirepesht>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ali Gholami Rudi <ali@rudi.ir>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20091110164006.GB816@lilem.mirepesht>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-10 at 08:40 -0800, Ali Gholami Rudi wrote:
> The values of r_idx and rx_ring are not used after the last time they
> are set in ixgbe_msix_clean_rx(), so they can be removed.
> 

Thanks for cleaning this up.

Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

> Signed-off-by: Ali Gholami Rudi <ali@rudi.ir>
> ---
>  drivers/net/ixgbe/ixgbe_main.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 5bd9e6b..6541c80 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -1344,8 +1344,6 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
>  	if (!q_vector->rxr_count)
>  		return IRQ_HANDLED;
>  
> -	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
> -	rx_ring = &(adapter->rx_ring[r_idx]);
>  	/* disable interrupts on this vector only */
>  	ixgbe_irq_disable_queues(adapter, ((u64)1 << q_vector->v_idx));
>  	napi_schedule(&q_vector->napi);


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
