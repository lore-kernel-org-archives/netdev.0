From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH 18/51] DMA-API: staging: et131x: replace
 dma_set_mask()+dma_set_coherent_mask() with new helper
Date: Mon, 23 Sep 2013 15:42:53 +0100
Message-ID: <20130923144253.GB3608@laugharne.auvation.com>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMm05-0007hG-5T@rmk-PC.arm.linux.org.uk>
 <1379691728.1681.15.camel@bwh-desktop.uk.level5networks.com>
 <20130921195531.GO12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, devel@driverdev.osuosl.org,
 netdev <netdev@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20130921195531.GO12758@n2100.arm.linux.org.uk>
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

On Sat, Sep 21, 2013 at 08:55:31PM +0100, Russell King - ARM Linux wrote:
> On Fri, Sep 20, 2013 at 04:42:08PM +0100, Ben Hutchings wrote:
> > On Thu, 2013-09-19 at 22:43 +0100, Russell King wrote:
> > > +	if (dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64)) ||
> > > +	    dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32))) {
> > 
> > Surely we want && here.
> 
> Good catch, exactly right.  Thanks for the review, here's the replacement
> patch:
> 
> 8<====
> From: Russell King <rmk+kernel@arm.linux.org.uk>
> Subject: [PATCH] DMA-API: staging: et131x: replace
>  dma_set_mask()+dma_set_coherent_mask() with new helper
> 
> Replace the following sequence:
> 
> 	dma_set_mask(dev, mask);
> 	dma_set_coherent_mask(dev, mask);
> 
> with a call to the new helper dma_set_mask_and_coherent().
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>  drivers/staging/et131x/et131x.c |   17 ++---------------
>  1 files changed, 2 insertions(+), 15 deletions(-)

Acked-by: Mark Einon <mark.einon@gmail.com>

Cheers,

Mark
