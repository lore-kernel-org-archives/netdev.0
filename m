From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH net-next v2 0/7] bnxt_en: Add interface to support RDMA
 driver.
Date: Tue, 6 Dec 2016 23:29:07 -0800
Message-ID: <20161207072907.GA20253@infradead.org>
References: <1481088381-30411-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Chan <michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1481088381-30411-1-git-send-email-michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2016 at 12:26:14AM -0500, Michael Chan wrote:
> This series adds an interface to support a brand new RDMA driver bnxt_re.
> The first step is to re-arrange some code so that pci_enable_msix() can
> be called during pci probe.  The purpose is to allow the RDMA driver to
> initialize and stay initialized whether the netdev is up or down.

Please switch form pci_enable_msix to pci_alloc_irq_vectors for any
changes to MSI-X code, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
