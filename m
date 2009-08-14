From: Jens Rosenboom <jens@mcbone.net>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Fri, 14 Aug 2009 08:22:05 +0200
Message-ID: <1250230925.6641.92.camel@fnki-nb00130>
References: <1250195675.28285.128.camel@Joe-Laptop.home>
	 <457D0D34-041E-43AE-BE31-241A19AA08B4@oracle.com>
	 <1250198022.28285.133.camel@Joe-Laptop.home>
	 <20090813.163133.199571497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, chuck.lever@oracle.com, brian.haley@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:34852 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755119AbZHNGWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2009 02:22:22 -0400
In-Reply-To: <20090813.163133.199571497.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-13 at 16:31 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Thu, 13 Aug 2009 14:13:42 -0700
> 
> > On Thu, 2009-08-13 at 17:02 -0400, Chuck Lever wrote:
> >> [ I would think user space in general should be using inet_pton(3)  
> >> everywhere for such interfaces, so the format of these addresses  
> >> wouldn't matter so much.  Probably impossible at this point. ]
> > 
> > David Miller is authoritative here.
> 
> In the final analysis, the risk is just too high to break
> userspace.  So let's play conservative here and not change
> the output for currently user visible stuff.

So just to clarify, do you want us to drop the whole thread and stay
with the clumsy output, or would you be o.k. with adding a new 
%p{something} and use that for kernel messages and maybe do some slow
migration of other stuff where possible?


