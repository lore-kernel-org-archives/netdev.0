From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH][6/12][RFC/v1] Add IPoIB (IP-over-InfiniBand) driver
Date: Mon, 22 Nov 2004 12:16:32 -0800
Message-ID: <52fz31d4gv.fsf@topspin.com>
References: <200411181046.6Dz1IPtDKfpgSXN9@topspin.com>
	<200411181046.Jj0jsF5E2KmiGN8f@topspin.com>
	<20041118200017.GA26976@infradead.org> <52sm71ex0l.fsf@topspin.com>
	<20041122153456.GA4905@infradead.org> <521xelemsm.fsf@topspin.com>
	<20041122200439.GA9635@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20041122200439.GA9635@infradead.org> (Christoph Hellwig's
 message of "Mon, 22 Nov 2004 20:04:39 +0000")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    Christoph> Good question.  In pratice I can't find a case were
    Christoph> DECLARE_PCI_UNMAP_ADDR() wouldn't simply work for
    Christoph> dma_*, but we should probably document that somewhere.

OK, I'll leave the DECLARE_PCI_UNMAP_ADDR() stuff in for now.  Longer
term maybe I'll submit a patch to add DECLARE_DMA_UNMAP_ADDR() et al
to clean this up.

Thanks,
  Roland
