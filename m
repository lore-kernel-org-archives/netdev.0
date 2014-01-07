From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH 10/15] irda: sh_irda: Enable driver compilation with COMPILE_TEST
Date: Tue, 07 Jan 2014 16:13:49 +0100
Message-ID: <63153015.VK19yFZrrS@avalon>
References: <1385515117-23664-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <1385515117-23664-11-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <2434798.8bvsZzgdNb@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <2434798.8bvsZzgdNb@avalon>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 11 December 2013 13:49:15 Laurent Pinchart wrote:
> Hi Samuel,
> 
> Could you please pick this patch up for v3.14 ?

Ping ?

> On Wednesday 27 November 2013 02:18:32 Laurent Pinchart wrote:
> > This helps increasing build testing coverage.
> > 
> > Cc: Samuel Ortiz <samuel@sortiz.org>
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Laurent Pinchart
> > <laurent.pinchart+renesas@ideasonboard.com>
> > Acked-by: Simon Horman <horms@verge.net.au>
> > ---
> > 
> >  drivers/net/irda/Kconfig | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
> > index 2a30193..cae5ee2 100644
> > --- a/drivers/net/irda/Kconfig
> > +++ b/drivers/net/irda/Kconfig
> > @@ -403,7 +403,8 @@ config MCS_FIR
> > 
> >  config SH_IRDA
> >  
> >  	tristate "SuperH IrDA driver"
> > 
> > -	depends on IRDA && ARCH_SHMOBILE
> > +	depends on IRDA
> > +	depends on ARCH_SHMOBILE || COMPILE_TEST
> > 
> >  	help
> >  	
> >  	  Say Y here if your want to enable SuperH IrDA devices.
-- 
Regards,

Laurent Pinchart

