From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] Support DMA-API debugging facility on PowerPC
Date: Thu, 2 Jul 2009 09:09:41 -0500
Message-ID: <70F1C213-8E4B-416D-9414-0D46710FAE32@kernel.crashing.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227286492.4901.208.camel@macbook.infradead.org> <20081121165722.GD1386@amd.com> <1227287215.4901.213.camel@macbook.infradead.org> <20081121171802.GK733@elte.hu> <20081121172046.GF1386@amd.com> <1227288269.4901.222.camel@macbook.infradead.org> <20081121172722.GG1386@amd.com> <1233873842.8135.6.camel@macbook.infradead.org> <1246454380.3681.1634.camel@macbook.infradead.org>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Joerg Roedel <joerg.roedel@amd.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux-Kernel List <linux-kernel@vger.kernel.org>,
	iommu@lists.linux-foundation.org, Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linuxppc-dev@ozlabs.org list" <linuxppc-dev@ozlabs.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54984 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbZGBOKX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 10:10:23 -0400
In-Reply-To: <1246454380.3681.1634.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jul 1, 2009, at 8:19 AM, David Woodhouse wrote:

>
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> Tested-by: Johannes Berg <johannes@sipsolutions.net>
> ---
> Some fixing from Johannes to make it apply to a current kernel...
>
> arch/powerpc/Kconfig                   |    1
> arch/powerpc/include/asm/dma-mapping.h |   47 +++++++++++++++++++++++ 
> +++++++---
> arch/powerpc/kernel/dma.c              |   11 +++++++
> 3 files changed, 55 insertions(+), 4 deletions(-)

How about CC'ng linuxppc-dev ;)

I'm not sure if Ben will take this for .31 at this point (with Linus's  
post -rc merge constraints) and if so we will probably move to <asm- 
generic/dma-mapping-common.h> for .32

- k
