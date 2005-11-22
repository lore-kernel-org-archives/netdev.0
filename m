From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] do not select NET_CLS
Date: Wed, 23 Nov 2005 00:12:36 +0100
Message-ID: <20051122231235.GC3963@stusta.de>
References: <20051116235813.GS5735@stusta.de> <20051121155955.GW16060@stusta.de> <4381F2D2.5000605@trash.net> <20051122.143713.101129339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, evil@g-house.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, zippel@linux-m68k.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030240AbVKVXMm@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20051122.143713.101129339.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2005 at 02:37:13PM -0800, David S. Miller wrote:
>...
> Changing config options of any kind can result in the main kernel
> image needing to be rebuilt.  One thing we can do to prevent human
> mistakes, is to make the "make modules" pass do a quick "is vmlinux
> uptodate?" check, and if not print out an error message explaining the
> situation and aborting the "make modules" attempt.

This won't work with CONFIG_IKCONFIG=y.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
