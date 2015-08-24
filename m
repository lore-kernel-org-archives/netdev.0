From: Scott Wood <scottwood@freescale.com>
Subject: Re: [v2 00/11] Freescale DPAA QBMan Drivers
Date: Mon, 24 Aug 2015 17:33:10 -0500
Message-ID: <1440455590.30043.58.camel@freescale.com>
References: <1439410497-19039-1-git-send-email-Roy.Pledge@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <Roy.Pledge@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439410497-19039-1-git-send-email-Roy.Pledge@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-08-12 at 16:14 -0400, Roy Pledge wrote:
> The Freescale Data Path Acceleration Architecture (DPAA) is a set of 
> hardware components on specific QorIQ multicore processors. This 
> architecture provides the infrastructure to support simplified sharing of 
> networking interfaces and accelerators by multiple CPU cores and the 
> accelerators.
> 
> The Queue Manager (QMan) is a hardware queue management block that allows 
> software and accelerators on the datapath to enqueue and dequeue frames in 
> order to communicate.
> 
> The Buffer Manager (BMan) is a hardware buffer pool management block that 
> allows software and accelerators on the datapath to acquire and release 
> buffers in order to build frames.
> 
> This patch set introduces the QBMan driver code that configures initializes 
> the QBMan hardware and provides APIs for software to use the frame queues 
> and buffer pools the blocks provide. These drivers provide the base 
> fuctionality for software to communicate with the other DPAA accelerators 
> on Freescale QorIQ processors.
> 
> Changes from v1:
>       - Cleanup Kconfig options
>       - Changed base QMan and BMan drivers to only be buit in.
>         Will add loadable support in future patch

CONFIG_FSL_BMAN is tristate -- is it not expected to work if you select 'm'?

>       - Replace panic() call with WARN_ON()

panic() is still there.

> 
> >       - Replaced PowerPC specific IO accessors with platform independent versions

PowerPC accessors, and other PPC-specfic things like cache flushing and 
memory barriers, are still there.

-Scott
