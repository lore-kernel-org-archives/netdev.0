From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 3/8] [I/OAT] Setup the networking subsystem as a DMA
 client
Date: Sat, 11 Mar 2006 01:00:23 -0800
Message-ID: <20060311010023.5919ec44.akpm@osdl.org>
References: <20060311022759.3950.58788.stgit@gitlost.site>
	<20060311022924.3950.33580.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932474AbWCKJCf@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060311022924.3950.33580.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech <christopher.leech@intel.com> wrote:
>
>  +#ifdef CONFIG_NET_DMA
>  +#include <linux/dmaengine.h>
>  +#endif

There are still a number of instances of this in the patch series.  Did you
decide to keep the ifdefs in there for some reason?
