From: Adrian Bunk <bunk@fs.tum.de>
Subject: Re: [2.6 patch] net/hamradio/dmascc: remove inlines
Date: Sat, 10 Jul 2004 19:16:28 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040710171628.GT28324@fs.tum.de>
References: <20040710010414.GX28324@fs.tum.de> <40F020C7.5010608@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40F020C7.5010608@pobox.com>
List-Id: netdev.vger.kernel.org

On Sat, Jul 10, 2004 at 01:00:55PM -0400, Jeff Garzik wrote:
>...
> It seems like you are going directly against the intent of the author, 
> with this patch.

The intend of the author might have been different - but the author 
didn't notice that his inlines never had any effect since the ordering 
of the functions was wrong.

I could send a patch to reorder the file to get the inlines working, but 
I heavily doubt inlining e.g. rx_on would be an improvement.

> 	Jeff

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

