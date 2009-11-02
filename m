From: David Miller <davem@davemloft.net>
Subject: Re: Patch: Fix userland build failure in linux/if_tunnel.h
Date: Mon, 02 Nov 2009 03:30:44 -0800 (PST)
Message-ID: <20091102.033044.206266489.davem@davemloft.net>
References: <4AEDCBA6.7040206@dresearch.de>
	<20091102135750.436a7b54@emcraft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sledz@dresearch.de, sledz@zone42.org, wd@denx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sposelenov@emcraft.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754922AbZKBLaV@vger.kernel.org>
In-Reply-To: <20091102135750.436a7b54@emcraft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Poselenov <sposelenov@emcraft.com>
Date: Mon, 2 Nov 2009 13:57:50 +0300

> Hm, I received a confirmation, that my fix was applied
> http://www.spinics.net/lists/netdev/msg103860.html
> 
> However, it indeed didn't find their way into the mainline.
> I have no idea why, received no objections.

That posting doesn't say that your patch got applied, it says
that Joe Perches's MAINTAINERS file patch got applied.

Look at the context of what I'm replying to, rather than the
fact that you see "Applied." and it happens to be in a thread
you started with another patch.

Your patch is not necessary, current iproute2 sources compile
just fine without your change.  iproute2 got changed to include
a local copy of linux/ip_tunnel.h which is modified so that it
compiles properly in userspace.
