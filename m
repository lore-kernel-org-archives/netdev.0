From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPV6: make ipv6_getsockopt_sticky honor user's buffer size
Date: Fri, 09 Mar 2007 09:49:32 +0900 (JST)
Message-ID: <20070309.094932.11513849.yoshfuji@linux-ipv6.org>
References: <20070308071048.GD10574@sequoia.sous-sol.org>
	<20070308.143804.21927824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chrisw@sous-sol.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34446 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423009AbXCIAtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 19:49:08 -0500
In-Reply-To: <20070308.143804.21927824.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070308.143804.21927824.davem@davemloft.net> (at Thu, 08 Mar 2007 14:38:04 -0800 (PST)), David Miller <davem@davemloft.net> says:

> From: Chris Wright <chrisw@sous-sol.org>
> Date: Wed, 7 Mar 2007 23:10:48 -0800
> 
> > Make sure not to copy_to_user more than user's buffer can handle (we
> > already checked the min, just use it) in ipv6_getsockopt_sticky.  And
> > while there, minor whitespace cleanup now that ipv6_getsockopt_sticky
> > call can nicely fit on one line.
> > 
> > Signed-off-by: Chris Wright <chrisw@sous-sol.org>
> 
> I wonder about this :-)
> 
> This gives the user now way to figure out that ipv6_optlen(hdr) is
> larger than the len they supplied.
> 
> In other situations usually we validate the length and return -EINVAL
> if it is too small.
> 
> That might be the thing to do in this case too.

We should give truncated result and return full length
from the POSIX POV.

--yoshfuji
