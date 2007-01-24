From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] process include/linux/if_{addr,link}.h with unifdef
Date: Wed, 24 Jan 2007 11:20:44 +0100
Message-ID: <20070124102044.GG17836@stusta.de>
References: <20070121191319.GO9093@stusta.de> <20070123.220517.115910657.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:1132 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750965AbXAXKUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 05:20:38 -0500
Content-Disposition: inline
In-Reply-To: <20070123.220517.115910657.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 23, 2007 at 10:05:17PM -0800, David Miller wrote:
> From: Adrian Bunk <bunk@stusta.de>
> Date: Sun, 21 Jan 2007 20:13:19 +0100
> 
> > After commit d3dcc077bf88806201093f86325ec656e4dbfbce, 
> > include/linux/if_{addr,link}.h should be processed with unifdef.
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> Applied, thanks Adrian.
> 
> I believe at least the 2.6.19 -stable branch will need
> this too, right?  Please submit to -stable as needed,
> and feel free to add my sign-off:
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

All my patch does is to remove "#ifndef __KERNEL__"'s around userspace 
#define's from the userspace headers, so it's purely cosmetical.

Except when userspace wrongly defines __KERNEL__, no 
header-y<->unifdef-y should ever have any non-cosmetical effect.

That said, we really want what I called "cosmetical" - not having
"#if{,n}def __KERNEL__" in any userspace headers - it's simply that this 
is not a serious bug.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

