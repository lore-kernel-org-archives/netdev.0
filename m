From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] pcnet32: Neaten and remove unnecessary OOM messages
Date: Tue, 01 Jul 2014 12:19:35 -0700 (PDT)
Message-ID: <20140701.121935.729962585105477131.davem@davemloft.net>
References: <1403550950.15811.15.camel@joe-AO725>
	<1403557507.20657.3.camel@joe-AO725>
	<1403740525.28663.6.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@frontier.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403740525.28663.6.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 25 Jun 2014 16:55:25 -0700

> Make the code flow a little better for 80 columns.
> 
> Use a consistent style for the RX and TX rings allocation.
> Use BIT macro.
> Use a temporary unsigned int entries for (1<<size).
> Remove the OOM messages as they duplicate the generic
> OOM and dump_stack() provided by the memory subsystem.
> Reflow allocs to 80 columns.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Acked-by: Don Fry <pcnet32@frontier.com>
> ---
> V2: Use pcnet32 as patch prefix, amd is too generic
> 
> Still depends on patch 1/22: pci-dma-compat: Add pci_zalloc_consistent helper

If this has a dependency on a patch I'm not added to my tree, I'm not
applying this one either.
