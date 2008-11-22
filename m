From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH 0/10] DMA-API debugging facility
Date: Sat, 22 Nov 2008 12:27:39 +0900
Message-ID: <20081122115802K.fujita.tomonori@lab.ntt.co.jp>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@redhat.com, tglx@linutronix.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: joerg.roedel@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:40040 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbYKVD3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 22:29:43 -0500
In-Reply-To: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Nov 2008 17:26:00 +0100
Joerg Roedel <joerg.roedel@amd.com> wrote:

> Hi,
> 
> this patchset introduces code to debug drivers usage of the DMA-API.
> Tests with hardware IOMMUs have shown several bugs in drivers regarding
> the usage of that API.
> Problems were found especially in network card drivers.

Especially? Have you met dma similar bugs with storage (scsi, etc)
drivers?


> This way driver developers get an idea where the problem is in their
> code.
> 
> Please review and send any objections or, if there are none, consider
> for inclusion ;)

This should be architecture independent code. Except for that, it
looks very useful.

Thanks,
