From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 08/22] amd: Use pci_zalloc_consistent
Date: Mon, 23 Jun 2014 12:15:50 -0700
Message-ID: <1403550950.15811.15.camel@joe-AO725>
References: <cover.1403530604.git.joe@perches.com>
	 <c7cdaa8e080157cdabb92278a4c3beba89b49070.1403530604.git.joe@perches.com>
	 <1403546524.12008.2.camel@Lunix2.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Don Fry <pcnet32@frontier.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403546524.12008.2.camel@Lunix2.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-06-23 at 11:02 -0700, Don Fry wrote:
> On Mon, 2014-06-23 at 06:41 -0700, Joe Perches wrote:
> > Remove the now unnecessary memset too.
[]
> > diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
[]
> > @@ -484,15 +484,13 @@ static void pcnet32_realloc_tx_ring(struct net_device *dev,
> >  
> >  	pcnet32_purge_tx_ring(dev);
> >  
> > -	new_tx_ring = pci_alloc_consistent(lp->pci_dev,
> > -					   sizeof(struct pcnet32_tx_head) *
> > -					   (1 << size),
> > -					   &new_ring_dma_addr);
> > +	new_tx_ring = pci_zalloc_consistent(lp->pci_dev,
> > +					    sizeof(struct pcnet32_tx_head) * (1 << size),
> 
> This causes the line length to be greater than 80 characters causing
> checkpatch to complain.

Which doesn't bother me a whit.
I prefer the multiply on the same line.

If you prefer 80 columns that strongly though,
let me know.
