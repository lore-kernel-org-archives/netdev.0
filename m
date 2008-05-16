From: Adrian Bunk <bunk@kernel.org>
Subject: Re: Top kernel oopses/warnings for the week of May 16th 2008
Date: Fri, 16 May 2008 21:04:26 +0300
Message-ID: <20080516180426.GA3284@cs181133002.pp.htv.fi>
References: <482DB93B.2080100@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:35058 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409AbYEPSGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 14:06:15 -0400
Content-Disposition: inline
In-Reply-To: <482DB93B.2080100@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 09:41:31AM -0700, Arjan van de Ven wrote:
>...
> Bug of the week
> ---------------
> Not in the top 10 (but barely not so), but upcoming fast is a bug that has a very
> distinct pattern.
> The backtraces are at http://www.kerneloops.org/searchweek.php?search=fput
>
> The pattern is that the kernel gets an invalid pointer passed to fput(),
> coming down from a select() system call done by the "wpa_supplicant" program.
> The fact that it is ONLY wpa_supplicant implicates the wireless/network stack.
> Another observation is that this only happens with 64 bit kernels, even though
> a large portion of the users uses 32 bit kernels. This implies that this is a 64-bit
> type of bug. It appears that the top 32 bit of the pointers is getting corrupted
> (the bottom part at least looks valid).
>...

Unless I misunderstand your webinterface another pattern is a "fc9" in 
the version string.

My first guess would be that it might be a problem in some code that is 
only in Fedora kernels?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

