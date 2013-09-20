From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 39/51] DMA-API: others: use dma_set_coherent_mask()
Date: Fri, 20 Sep 2013 07:16:52 -0500
Message-ID: <20130920121652.GA7630@mtj.dyndns.org>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMnNq-0007s4-HN@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 David Airlie <airlied@linux.ie>, linux-mmc@vger.kernel.org,
 linux-fbdev@vger.kernel.org, linux-nvme@lists.infradead.org,
 linux-ide@vger.kernel.org, devel@driverdev.osuosl.org,
 linux-samsung-soc@vger.kernel.org, Joonyoung Shim <jy0922.shim@samsung.com>,
 linux-scsi@vger.kernel.org, e1000-devel@lists.sourceforge.net,
 Seung-Woo Kim <sw0312.kim@samsung.com>, b43-dev@lists.infradead.org,
 linux-media@vger.kernel.org, devicetree@vger.kernel.org,
 Inki Dae <inki.dae@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>,
 dri-devel@lists.freedesktop.org, linux-tegra@vger.kernel.org,
 linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <E1VMnNq-0007s4-HN@rmk-PC.arm.linux.org.uk>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 20, 2013 at 12:11:38AM +0100, Russell King wrote:
> The correct way for a driver to specify the coherent DMA mask is
> not to directly access the field in the struct device, but to use
> dma_set_coherent_mask().  Only arch and bus code should access this
> member directly.
> 
> Convert all direct write accesses to using the correct API.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Acked-by: Tejun Heo <tj@kernel.org>

The patch is pretty widely spread.  I don't mind how it gets routed
but what's the plan?

Thanks.

-- 
tejun
