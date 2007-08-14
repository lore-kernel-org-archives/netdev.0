From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2/13] cxgb3 - Update rx coalescing length
Date: Tue, 14 Aug 2007 16:22:05 -0700
Message-ID: <46C2391D.1060608@chelsio.com>
References: <20070811062939.8040.31490.stgit@speedy5> <46C14096.3020905@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:29167 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754232AbXHNXWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 19:22:11 -0400
In-Reply-To: <46C14096.3020905@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
>
> Divy Le Ray wrote:
> > From: Divy Le Ray <divy@chelsio.com>
> >
> > Set max Rx coalescing length to 12288
> >
> > Signed-off-by: Divy Le Ray <divy@chelsio.com>
> > ---
> >
> >  drivers/net/cxgb3/common.h |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
> > index c46c249..55922ed 100644
> > --- a/drivers/net/cxgb3/common.h
> > +++ b/drivers/net/cxgb3/common.h
> > @@ -104,7 +104,7 @@ enum {
> >       PROTO_SRAM_LINES = 128, /* size of TP sram */
> >  };
> > 
> > -#define MAX_RX_COALESCING_LEN 16224U
> > +#define MAX_RX_COALESCING_LEN 12288U
>
> neither the patch nor description explains -why-
>

We're seeing back pressure from PCIe with large bursts, this patch 
allows to cut down on the burst size.

Divy

