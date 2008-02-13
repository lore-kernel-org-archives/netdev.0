From: Ben Nizette <bn@niasdigital.com>
Subject: Re: BUG: 2.6.25-rc1: iptables postrouting setup causes oops
Date: Thu, 14 Feb 2008 09:41:26 +1100
Message-ID: <1202942486.3299.69.camel@moss.renham>
References: <1202816761.3299.19.camel@moss.renham>
	 <20080213004829.fd8afdc7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@atmel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail01.adl6.internode.on.net ([203.16.214.146]:5648 "EHLO
	ipmail01.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751563AbYBMWiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 17:38:05 -0500
In-Reply-To: <20080213004829.fd8afdc7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-02-13 at 00:48 -0800, Andrew Morton wrote:
> On Tue, 12 Feb 2008 22:46:01 +1100 Ben Nizette <bn@niasdigital.com> wrote:

> > Perfectly repeatable.
> 
> If my theory is correct, changing pretty much anything in the kernel config
> might just make it go away.  But still, it would be most valuable if you
> could try running a bisection search, as described in
> http://www.kernel.org/doc/local/git-quick.html, thanks.
> 

Hm, not as stable a bug as I'd thought.  I have performed a number of
bisections with different start points and they have not converged on
the same patch twice.  Even bisections with the _same_ start point
didn't always converge on the same patch.

What ever the problem is it isn't immediately apparent in latest git so
I guess we'll just have to keep our eyes peeled.

Thanks,
	--Ben.
