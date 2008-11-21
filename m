From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 01/10] x86: add Kconfig entry for DMA-API debugging
Date: Fri, 21 Nov 2008 17:40:14 +0100
Message-ID: <20081121164014.GB733@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-2-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:48116 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752688AbYKUQkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 11:40:35 -0500
Content-Disposition: inline
In-Reply-To: <1227284770-19215-2-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +config DMA_API_DEBUG
> +	default n

'default n' can be omitted in general from interactive Kconfig 
entries.

> +	bool "Enable debugging of DMA-API usage"
> +	depends on X86

perhaps add a proper dependency on iommu or swiotlb presence as well - 
in case we decide to make it all disable-able again and dont have the 
callbacks present?

	Ingo
