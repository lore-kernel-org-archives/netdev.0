From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH][6/12][RFC/v1] Add IPoIB (IP-over-InfiniBand) driver
Date: Mon, 22 Nov 2004 15:34:56 +0000
Message-ID: <20041122153456.GA4905@infradead.org>
References: <200411181046.6Dz1IPtDKfpgSXN9@topspin.com> <200411181046.Jj0jsF5E2KmiGN8f@topspin.com> <20041118200017.GA26976@infradead.org> <52sm71ex0l.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roland Dreier <roland@topspin.com>
Content-Disposition: inline
In-Reply-To: <52sm71ex0l.fsf@topspin.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> We can switch to dma_* (and in fact I see some reasons to do so).
> However Greg KH suggested sticking with pci_* stuff until there's a
> non-PCI device to deal with.

That just means avoidable interface changes sooner or later.  The dma_
interfaces also have the added benefit of allowing better control of the
type of consistant allocation interface.

Note that pathscale already has direct to HT infiniband components, but
it's not sure whether they'll ever be supported by the OpenIB codebase.
