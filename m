From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 0/10] DMA-API debugging facility
Date: Sat, 22 Nov 2008 10:29:04 +0100
Message-ID: <20081122092904.GF29705@8bytes.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <20081122115802K.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joerg.roedel@amd.com, netdev@vger.kernel.org, tglx@linutronix.de,
	mingo@redhat.com, linux-kernel@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8bytes.org ([88.198.83.132]:33298 "EHLO 8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752032AbYKVJ3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2008 04:29:07 -0500
Content-Disposition: inline
In-Reply-To: <20081122115802K.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 22, 2008 at 12:27:39PM +0900, FUJITA Tomonori wrote:
> On Fri, 21 Nov 2008 17:26:00 +0100
> Joerg Roedel <joerg.roedel@amd.com> wrote:
> 
> > Hi,
> > 
> > this patchset introduces code to debug drivers usage of the DMA-API.
> > Tests with hardware IOMMUs have shown several bugs in drivers regarding
> > the usage of that API.
> > Problems were found especially in network card drivers.
> 
> Especially? Have you met dma similar bugs with storage (scsi, etc)
> drivers?

No. For me the code only triggered network card drivers. Namely the
ixgbe, tg3 and bnx2 driver.

> 
> > This way driver developers get an idea where the problem is in their
> > code.
> > 
> > Please review and send any objections or, if there are none, consider
> > for inclusion ;)
> 
> This should be architecture independent code. Except for that, it
> looks very useful.

Thanks,

Joerg
