From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: Top kernel oopses/warnings for the week of May 16th 2008
Date: Mon, 19 May 2008 23:53:48 -0400
Message-ID: <20080520035348.GA32472@codemonkey.org.uk>
References: <482DB93B.2080100@linux.intel.com> <20080516180426.GA3284@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from testure.choralone.org ([194.9.77.134]:49929 "EHLO
	testure.choralone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609AbYETDw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 23:52:56 -0400
Content-Disposition: inline
In-Reply-To: <20080516180426.GA3284@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 09:04:26PM +0300, Adrian Bunk wrote:
 > On Fri, May 16, 2008 at 09:41:31AM -0700, Arjan van de Ven wrote:
 > >...
 > > Bug of the week
 > > ---------------
 > > Not in the top 10 (but barely not so), but upcoming fast is a bug that has a very
 > > distinct pattern.
 > > The backtraces are at http://www.kerneloops.org/searchweek.php?search=fput
 > >
 > > The pattern is that the kernel gets an invalid pointer passed to fput(),
 > > coming down from a select() system call done by the "wpa_supplicant" program.
 > > The fact that it is ONLY wpa_supplicant implicates the wireless/network stack.
 > > Another observation is that this only happens with 64 bit kernels, even though
 > > a large portion of the users uses 32 bit kernels. This implies that this is a 64-bit
 > > type of bug. It appears that the top 32 bit of the pointers is getting corrupted
 > > (the bottom part at least looks valid).
 > >...
 > 
 > Unless I misunderstand your webinterface another pattern is a "fc9" in 
 > the version string.

Unsurprising really given we just did a release, and not many other distros
are enabling kerneloops by default yet.

 > My first guess would be that it might be a problem in some code that is 
 > only in Fedora kernels?

Very likely, though it's worth noting that all the wireless patches we have
in f9 are from wireless.git, so they're valid 2.6.26-rc bugs 

	Dave

-- 
http://www.codemonkey.org.uk
