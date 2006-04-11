From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Wed, 12 Apr 2006 00:30:24 +0200
Message-ID: <20060411223024.GA6543@ens-lyon.fr>
References: <1144719972.19353.24.camel@localhost.localdomain> <20060410.224933.39567033.davem@davemloft.net> <1144788541.19353.41.camel@localhost.localdomain> <20060411.143407.74615246.davem@davemloft.net> <1144794077.19353.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, mb@bu3sch.de,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	linux-kernel@vger.kernel.org, linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751179AbWDKW3i@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Disposition: inline
In-Reply-To: <1144794077.19353.53.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2006 at 08:21:17AM +1000, Benjamin Herrenschmidt wrote:
> 
> > I still think we shouldn't reward shit hardware by complicating
> > up our DMA mappings internals. :-)
> 
> BTW. In the meantime, can't that driver work in PIO only mode ?

yes, I think you just have to have the pci_set_dma_mask fail with
DMA30BIT_MASK.

regards,

Benoit

-- 
powered by bash/screen/(urxvt/fvwm|linux-console)/gentoo/gnu/linux OS
