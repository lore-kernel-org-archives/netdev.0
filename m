From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] tc35815 driver update (part 1)
Date: Fri, 02 Mar 2007 20:11:14 -0500
Message-ID: <45E8CB32.5060008@garzik.org>
References: <20070302.232407.05600700.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	netdev@vger.kernel.org, sshtylyov@ru.mvista.com
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55483 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992848AbXCCBLT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:11:19 -0500
In-Reply-To: <20070302.232407.05600700.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Atsushi Nemoto wrote:
> Current tc35815 driver is very obsolete and less maintained for a long
> time.  Replace it with a new driver based on one from CELF patch
> archive.  It was for 2.6.10 kernel so some adjustment and cleanup are
> added. (remove config.h, SA_ to IRQF_ conversion, etc.)
> 
> Major advantages are:
> 
> * Independent of JMR3927.
>   (Actually independent of MIPS, but AFAIK the chip is used only on
>    MIPS platforms)
> * TX4938 support.
> * 64-bit proof.
> * Asynchronous and on-demand auto negotiation.
> * High performance on non-coherent architecture.
> * ethtool support.
> * Many bugfixes and cleanups.
> 
> And next patch add further improvements/bugfixes/cleanups.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
> This is a patch against current linux-mips.org git-tree.
> 
>  drivers/net/Kconfig     |    3 
>  drivers/net/tc35815.c   | 2070 +++++++++++++++++++++++++++++++---------------
>  include/linux/pci_ids.h |    1 
>  3 files changed, 1440 insertions(+), 634 deletions(-)

Would you be kind enough to

a) provide a URL to a .c file (or post it, if it's under 100K) so that 
we may more easily review this

b) combine both patches into a single patch.  might as well, since it's 
a rewrite.

c) rediff your patch against linux-2.6.git + Ralf's killall removal 
patch, and resend.  There were some minor conflicting changes that 
appeared, though these changes will certainly become irrelevant once 
your new driver is merged.


