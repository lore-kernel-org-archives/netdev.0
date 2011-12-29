From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on
 low-end broads.
Date: Thu, 29 Dec 2011 17:05:14 -0500 (EST)
Message-ID: <20111229.170514.1766899380937848638.davem@davemloft.net>
References: <CACPM=kXOddA+T6vQPijR6sh8x5cMO=4baKGeKxEmMKG896Lz4g@mail.gmail.com>
	<20111229153902.GB21946@electric-eye.fr.zoreil.com>
	<20111229183902.GC21946@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gurligebis@gentoo.org, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111229183902.GC21946@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 29 Dec 2011 19:39:02 +0100

> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
>> Feel free to try the extra "new year's eve week end is getting closer"
>> patch below (against net-next).
>> 
>> You have been warned.
> 
> The one below could be a bit better.

Obviously you'll need to resolve the use of rp->lock as an IRQ safe lock
in {get,src}_wol() so that this lock is consistently used as a BH safe
lock.  Your "Huh?" comments make it clear you are aware of this TODO. :-)

But other than that this patch looks good to me, just some testing and
debugging are needed.
