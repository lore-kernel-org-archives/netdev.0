From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 3/9] bnx2x: annotate addr_hi/addr_lo as le32
Date: Thu, 22 Jan 2009 10:13:34 -0800
Message-ID: <1232648015.9701.50.camel@brick>
References: <1232517048.9701.21.camel@brick>
	 <1232646585.29087.87.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:63516 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890AbZAVSNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 13:13:37 -0500
Received: by wf-out-1314.google.com with SMTP id 27so5076341wfd.4
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2009 10:13:36 -0800 (PST)
In-Reply-To: <1232646585.29087.87.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-22 at 19:49 +0200, Eilon Greenstein wrote:
> On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> > Remove a completely unused structure definition as well.
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> 
> [...]
> >  
> > diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> > index 2f8d64c..021c31c 100644
> > --- a/drivers/net/bnx2x_main.c
> > +++ b/drivers/net/bnx2x_main.c
> > @@ -987,8 +987,8 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
> >  	__free_pages(page, PAGES_PER_SGE_SHIFT);
> >  
> >  	sw_buf->page = NULL;
> > -	sge->addr_hi = 0;
> > -	sge->addr_lo = 0;
> > +	sge->addr_hi = cpu_to_le32(0);
> > +	sge->addr_lo = cpu_to_le32(0);
> >  }
> 
> I prefer to keep zeros as zeros. I find it less readable with the
> cpu_to_le macro. I also noticed that it does not add a sparse warning,
> so on the combined image I will keep the zeros as zeros.
>  
> Other than that, the patch looks fine

Sparse will only warn if CHECK_ENDIAN is set as addr_hi/lo was just marked
as a le32, how do you think I noticed this line needed changing ;-)

Harvey



