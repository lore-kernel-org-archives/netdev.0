From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tc35815 driver update (take 2)
Date: Tue, 06 Mar 2007 06:20:04 -0500
Message-ID: <45ED4E64.5030404@garzik.org>
References: <20070303.235459.25478204.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	netdev@vger.kernel.org, sshtylyov@ru.mvista.com
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53326 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934080AbXCFLUK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:20:10 -0500
In-Reply-To: <20070303.235459.25478204.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Atsushi Nemoto wrote:
> Current tc35815 driver is very obsolete and less maintained for a long
> time.  Replace it with a new driver based on one from CELF patch
> archive.
> 
> Major advantages of CELF version (version 1.23, for kernel 2.6.10) are:
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
> And improvoments since version 1.23 are:
> 
> * TX4939 support.
> * NETPOLL support.
> * NAPI support. (disabled by default)
> * Reduce memcpy on receiving.
> * PM support.
> * Many cleanups and bugfixes.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> 
>  drivers/net/Kconfig     |    3 
>  drivers/net/tc35815.c   | 2587 ++++++++++++++++++++++++++++++++++------------
>  include/linux/pci_ids.h |    2 
>  3 files changed, 1917 insertions(+), 675 deletions(-)

applied to #upstream, let's give it a good review while it hangs out in 
libata-dev.git#ALL and -mm


