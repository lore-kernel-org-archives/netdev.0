From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 5/8] [I/OAT] Structure changes for TCP recv offload to
 I/OAT
Date: Sat, 4 Mar 2006 23:19:51 -0800
Message-ID: <20060304231951.0e83e23b.akpm@osdl.org>
References: <20060303214036.11908.10499.stgit@gitlost.site>
	<20060303214229.11908.19898.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752149AbWCEHVZ@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060303214229.11908.19898.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech <christopher.leech@intel.com> wrote:
>
> +#ifdef CONFIG_NET_DMA
>  +#include <linux/dmaengine.h>
>  +#endif

Please move the ifdefs into the header and include it unconditionally
(entire patchset).
