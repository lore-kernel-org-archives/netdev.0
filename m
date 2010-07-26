From: Simon Horman <horms@verge.net.au>
Subject: Re: IPv6 Anycast?
Date: Mon, 26 Jul 2010 17:44:21 +0900
Message-ID: <20100726084418.GA14903@verge.net.au>
References: <4C48B90B.60304@actusa.net>
 <alpine.DEB.1.10.1007230554240.9875@uplift.swm.pp.se>
 <4C491AD4.9070103@actusa.net>
 <alpine.DEB.1.10.1007230748380.9875@uplift.swm.pp.se>
 <4C49B163.8090400@actusa.net>
 <4C49C352.6010701@astaro.com>
 <4C49C92D.30705@actusa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ulrich Weber <uweber@astaro.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>, netdev@vger.kernel.org
To: Stuart Sheldon <stu@actusa.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40506 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab0GZIoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 04:44:25 -0400
Content-Disposition: inline
In-Reply-To: <4C49C92D.30705@actusa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 23, 2010 at 09:54:05AM -0700, Stuart Sheldon wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA256
> 
> Hi Ulrich,
> 
> Thanks, that resolves half the issue. So as of right now, there is no
> userspace program to add anycast addresses?

I was hoping to have some useful information, but alas I failed on that count.

Looking at ip(8) it seems that the following ought to work:

ip addr add fd16:a2f5:c4d7::7/48 anycast fd16:a2f5:c4d7::8 dev eth0

However, it seems not to, and then I found this in the manpage :-(

	anycast   -   not  implemented  the  destinations are  anycast
	addresses assigned to this host.  They are mainly equivalent to
	local with one difference: such addresses are invalid when used as
	the source address of any packet.

