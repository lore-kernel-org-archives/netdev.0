From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Sat, 8 Sep 2007 13:00:36 +0100
Message-ID: <20070908120036.GB8478@infradead.org>
References: <1188599815.5176.12.camel@dell> <46E1D27F.2040701@cs.wisc.edu> <20070908084127G.tomof@acm.org> <46E2884B.2070107@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: FUJITA Tomonori <tomof@acm.org>, open-iscsi@googlegroups.com,
	davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com, fujita.tomonori@lab.ntt.co.jp
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:60415 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbXIHMBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 08:01:03 -0400
Content-Disposition: inline
In-Reply-To: <46E2884B.2070107@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 08, 2007 at 07:32:27AM -0400, Jeff Garzik wrote:
> FUJITA Tomonori wrote:
> >Yeah, iommu code ignores the lld limitations (the problem is that the
> >lld limitations are in request_queue and iommu code can't access to
> >request_queue). There is no way to tell iommu code about the lld
> >limitations.
> 
> 
> This fact very much wants fixing.


Absolutely.  Unfortunately everyone wastes their time on creating workarounds
instead of fixing the underlying problem.
