From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH][6/12][RFC/v1] Add IPoIB (IP-over-InfiniBand) driver
Date: Mon, 22 Nov 2004 10:55:21 -0800
Message-ID: <521xelemsm.fsf@topspin.com>
References: <200411181046.6Dz1IPtDKfpgSXN9@topspin.com>
	<200411181046.Jj0jsF5E2KmiGN8f@topspin.com>
	<20041118200017.GA26976@infradead.org> <52sm71ex0l.fsf@topspin.com>
	<20041122153456.GA4905@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20041122153456.GA4905@infradead.org> (Christoph Hellwig's
 message of "Mon, 22 Nov 2004 15:34:56 +0000")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    Christoph> That just means avoidable interface changes sooner or
    Christoph> later.  The dma_ interfaces also have the added benefit
    Christoph> of allowing better control of the type of consistant
    Christoph> allocation interface.

Is there a dma_xxx equivalent to DECLARE_PCI_UNMAP_ADDR(),
pci_unmap_addr_set() and friends, or does a driver always have to save
off the DMA address from dma_map_xxx?

Thanks, 
  Roland
