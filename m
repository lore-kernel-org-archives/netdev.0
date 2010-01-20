From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Wed, 20 Jan 2010 10:09:36 -0800
Message-ID: <20100120100936.16e10507@nehalam>
References: <20100120094103.GA6225@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Michael Breuer <mbreuer@majjas.com>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45754 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752003Ab0ATSKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 13:10:53 -0500
In-Reply-To: <20100120094103.GA6225@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jan 2010 09:41:03 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> It seems using the same length (even without pci_unmap_len()) is
> crucial here, but I hope maintainers (added to CC) will take care.
> 
> Btw, it's not tested yet, but it might affect CONFIG_DMAR problems.
> 
> Thanks,
> Jarek P.

Update Documentation/PCI-DMA-mapping as well please.

-- 
