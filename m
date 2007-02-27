From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 7/7] cxgb3 - Add SW LRO support
Date: Tue, 27 Feb 2007 08:17:15 -0600
Message-ID: <1172585835.11870.13.camel@stevo-desktop>
References: <20070225004423.20903.17036.stgit@localhost.localdomain>
	 <20070226051304.GA13626@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:55834 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751624AbXB0ORR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 09:17:17 -0500
In-Reply-To: <20070226051304.GA13626@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-02-26 at 05:13 +0000, Christoph Hellwig wrote:
> On Sat, Feb 24, 2007 at 04:44:23PM -0800, divy@chelsio.com wrote:
> > From: Divy Le Ray <divy@chelsio.com>
> > 
> > Add all-in-sw lro support.
> 
> Doing this in a LLDD doesn't sound like a good idea.  Have you
> tried doing this in the core networking code instead?

It looks like both Netxen and Neterion drivers already have this.  So I
think for now the LLDD implements LRO.  The stack supports it by virtue
of allowing fragmented skbs that are bigger than the MTU.

Other drivers implementing LRO:

drivers/net/s2io.c
drivers/net/netxen/

Steve.

