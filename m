From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [IOC3] IP27: Really set PCI64_ATTR_VIRTUAL, not PCI64_ATTR_PREC.
Date: Tue, 20 Jun 2006 11:02:36 +0100
Message-ID: <20060620100236.GA4288@linux-mips.org>
References: <20060617175738.GA4346@linux-mips.org> <200606201015.01323.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:29327 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S932564AbWFTKEC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 06:04:02 -0400
Received: from localhost.localdomain ([127.0.0.1]:41360 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133456AbWFTKD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 11:03:59 +0100
To: Ingo Oeser <netdev@axxeo.de>
Content-Disposition: inline
In-Reply-To: <200606201015.01323.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2006 at 10:15:01AM +0200, Ingo Oeser wrote:
> From:	Ingo Oeser <netdev@axxeo.de>
> To:	Ralf Baechle <ralf@linux-mips.org>
> Subject: Re: [IOC3] IP27: Really set PCI64_ATTR_VIRTUAL, not PCI64_ATTR_PREC.
> Date:	Tue, 20 Jun 2006 10:15:01 +0200
> Cc:	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
> Content-Type: text/plain;
>   charset="iso-8859-1"
> 
> Hi Ralf,
> 
> Ralf Baechle :
> > IOC3's homegrown DMA mapping functions that are used to optimize things
> > a little on IP27 set the wrong bit.
> 
> What about using a symbol instead of magic numbers?
> That way one at least sees the intention of the coder.
>  
> > Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> > 
> > diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
> > index ae71ed5..e76e6e7 100644
> > --- a/drivers/net/ioc3-eth.c
> > +++ b/drivers/net/ioc3-eth.c
> > @@ -145,7 +145,7 @@ static inline struct sk_buff * ioc3_allo
> >  static inline unsigned long ioc3_map(void *ptr, unsigned long vdev)
> >  {
> >  #ifdef CONFIG_SGI_IP27
> > -	vdev <<= 58;   /* Shift to PCI64_ATTR_VIRTUAL */
> > +	vdev <<= 57;   /* Shift to PCI64_ATTR_VIRTUAL */
> 
> So please use a symbolic value here.

It is a hack and meant to look like one, loudly marked with #ifdef.

  Ralf
