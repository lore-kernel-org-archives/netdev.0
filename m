From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 02/12] ftgmac100: Move ftgmac100_hard_start_xmit() around
Date: Sat, 08 Apr 2017 09:14:11 +1000
Message-ID: <1491606851.4166.162.camel@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
         <20170407033105.29558-3-benh@kernel.crashing.org>
         <10736779-3bcf-e797-cfaa-bdcc12b9d5f4@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57382 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754070AbdDGXOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 19:14:25 -0400
In-Reply-To: <10736779-3bcf-e797-cfaa-bdcc12b9d5f4@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-07 at 13:09 +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 4/7/2017 6:30 AM, Benjamin Herrenschmidt wrote:
> 
> > Move it below ftgmac100_xmit() and the rest of the tx path
> > 
> > No code change.
> > 
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > ---
> >  drivers/net/ethernet/faraday/ftgmac100.c | 59 ++++++++++++++++--
> > --------------
> >  1 file changed, 30 insertions(+), 29 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/faraday/ftgmac100.c
> > b/drivers/net/ethernet/faraday/ftgmac100.c
> > index f4b719214..3966c7a 100644
> > --- a/drivers/net/ethernet/faraday/ftgmac100.c
> > +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> > @@ -63,6 +63,7 @@ struct ftgmac100 {
> >  	u32 rxdes0_edorr_mask;
> > 
> >  	/* Tx ring */
> > +	struct sk_buff *tx_skbs[TX_QUEUE_ENTRIES];
> 
>     "No code change", really?

Patch splitting accident, thanks for pointing it out. I'll fix it up in
the next round.

> 
> >  	unsigned int tx_clean_pointer;
> >  	unsigned int tx_pointer;
> >  	unsigned int tx_pending;
> 
> [...]
> 
> MBR, Sergei
