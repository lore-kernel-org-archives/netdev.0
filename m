From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.11 3/8] tg3: Add msi support for 5750 C0
Date: Tue, 22 Mar 2005 15:56:25 -0500
Message-ID: <42408679.7020407@pobox.com>
References: <B1508D50A0692F42B217C22C02D84972020F3E23@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3E23@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> Add MSI support for 5750 C0 and newer chips. MSI is handled by a new
> interrupt service routine that is very similar to the existing
> tg3_interrupt() for INTx mode. The MSI version is optimized by not checking
> for shared interrupt and not flushing the status block.
> 
> The code is also changed to reference the irq from tp->pdev->irq instead of
> dev->irq.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com

I would prefer that a new 'static inline' function was created, 
containing the core interrupt handler code.

This avoids the code duplication you have in this patch, in new function 
tg3_msi().

	Jeff
