From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] net: support for NS8390 based ethernet on
 ColdFire CPU boards
Date: Thu, 12 Jul 2012 07:55:31 -0700 (PDT)
Message-ID: <20120712.075531.836132484757271226.davem@davemloft.net>
References: <1341445800-396-1-git-send-email-gerg@snapgear.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org
To: gerg@snapgear.com
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1341445800-396-1-git-send-email-gerg@snapgear.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <gerg@snapgear.com>
Date: Thu, 5 Jul 2012 09:49:58 +1000

> 
> This is version 2 of patches that add platform support for using the NS8390
> based ethernet ports used on some ColdFire CPU boards. This version
> incorporates only minor changes from the first.
> 
> Patches to use these NS8390 devices on ColdFire boards have existed
> out-of-tree for years. Some of the base IO definitions (those in
> arch/m68k/include/asm/mcfne.h) have been in mainline, but unused for most
> of that time.
> 
> The first patch just neatens up mcfne.h (moving it to mcf8390.h). The
> second patch is the platform driver. The first patch would normaly just
> go through the m68knommu git tree, but I figured keeping these together made
> more sense.

Applied, thanks.

Can you explain why we've had this completely unused header
file mcfne.h in the tree?  Was it used by some external driver
sources that were never merged?
