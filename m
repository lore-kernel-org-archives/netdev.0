From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [IOC3] IP27: Really set PCI64_ATTR_VIRTUAL, not PCI64_ATTR_PREC.
Date: Tue, 20 Jun 2006 10:15:01 +0200
Message-ID: <200606201015.01323.netdev@axxeo.de>
References: <20060617175738.GA4346@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:989 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S965152AbWFTIPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 04:15:23 -0400
To: Ralf Baechle <ralf@linux-mips.org>
In-Reply-To: <20060617175738.GA4346@linux-mips.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ralf,

Ralf Baechle :
> IOC3's homegrown DMA mapping functions that are used to optimize things
> a little on IP27 set the wrong bit.

What about using a symbol instead of magic numbers?
That way one at least sees the intention of the coder.
 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
> index ae71ed5..e76e6e7 100644
> --- a/drivers/net/ioc3-eth.c
> +++ b/drivers/net/ioc3-eth.c
> @@ -145,7 +145,7 @@ static inline struct sk_buff * ioc3_allo
>  static inline unsigned long ioc3_map(void *ptr, unsigned long vdev)
>  {
>  #ifdef CONFIG_SGI_IP27
> -	vdev <<= 58;   /* Shift to PCI64_ATTR_VIRTUAL */
> +	vdev <<= 57;   /* Shift to PCI64_ATTR_VIRTUAL */

So please use a symbolic value here.
  

Regards

Ingo Oeser
