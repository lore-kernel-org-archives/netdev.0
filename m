From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 10/14] atm: Removed redundant check on unsigned variable
Date: Mon, 31 Dec 2012 10:18:51 -0500
Message-ID: <20121231101851.22526c61@thirdoffive.cmf.nrl.navy.mil>
References: <1353048646-10935-1-git-send-email-tushar.behera@linaro.org>
	<1353048646-10935-11-git-send-email-tushar.behera@linaro.org>
	<50DD2B34.9070905@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, patches@linaro.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: Tushar Behera <tushar.behera@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:42715 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab2LaPTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:19:11 -0500
In-Reply-To: <50DD2B34.9070905@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

On Fri, 28 Dec 2012 10:46:36 +0530
Tushar Behera <tushar.behera@linaro.org> wrote:

> Ping.
> 
> On 11/16/2012 12:20 PM, Tushar Behera wrote:
> > No need to check whether unsigned variable is less than 0.
> > 
> > CC: Chas Williams <chas@cmf.nrl.navy.mil>
> > CC: linux-atm-general@lists.sourceforge.net
> > CC: netdev@vger.kernel.org
> > Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
> > ---
> >  drivers/atm/fore200e.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
> > index 361f5ae..fdd3fe7 100644
> > --- a/drivers/atm/fore200e.c
> > +++ b/drivers/atm/fore200e.c
> > @@ -972,7 +972,7 @@ int bsq_audit(int where, struct host_bsq* bsq, int scheme, int magn)
> >  		   where, scheme, magn, buffer->index, buffer->scheme);
> >  	}
> >  
> > -	if ((buffer->index < 0) || (buffer->index >= fore200e_rx_buf_nbr[ scheme ][ magn ])) {
> > +	if (buffer->index >= fore200e_rx_buf_nbr[ scheme ][ magn ]) {
> >  	    printk(FORE200E "bsq_audit(%d): queue %d.%d, out of range buffer index = %ld !\n",
> >  		   where, scheme, magn, buffer->index);
> >  	}
> > 
> 
> 
