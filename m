From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Linux 2.6.26.4
Date: Mon, 8 Sep 2008 08:12:53 -0700
Message-ID: <20080908081253.d3100d88.randy.dunlap@oracle.com>
References: <20080908143625.GC7311@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org, stable@kernel.org
To: Greg KH <gregkh@suse.de>, netdev <netdev@vger.kernel.org>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:23335 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbYIHPOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 11:14:03 -0400
In-Reply-To: <20080908143625.GC7311@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Sep 2008 07:36:25 -0700 Greg KH wrote:

> We (the -stable team) are announcing the release of the 2.6.26.4
> kernel.
> 
> It contains lots of bugfixes, all over the map.  Any users of the 2.6.26
> kernel series should upgrade to this version.  For details on the fixes,
> see the changelog entries and the diffstat below.
> 
> I'll also be replying to this message with a copy of the patch between
> 2.6.26.3 and 2.6.26.4
> 
> The updated 2.6.26.y git tree can be found at:
>         git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-2.6.26.y.git
> and can be browsed at the normal kernel.org git web browser:
>         http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.26.y.git;a=summary

>  include/linux/pim.h                |   45 -----------------

That file is still used by ./net/ipv6/ip6mr.c:#include <linux/pim.h>
so there are build errors...

net/ipv6/ip6mr.c:48:23: error: linux/pim.h: No such file or directory
net/ipv6/ip6mr.c:354: error: dereferencing pointer to incomplete type
net/ipv6/ip6mr.c:358: error: dereferencing pointer to incomplete type
net/ipv6/ip6mr.c:358: error: 'PIM_VERSION' undeclared (first use in this function)
net/ipv6/ip6mr.c:358: error: (Each undeclared identifier is reported only once
net/ipv6/ip6mr.c:358: error: for each function it appears in.)
net/ipv6/ip6mr.c:358: error: 'PIM_REGISTER' undeclared (first use in this function)
net/ipv6/ip6mr.c:359: error: dereferencing pointer to incomplete type
net/ipv6/ip6mr.c:359: error: 'PIM_NULL_REGISTER' undeclared (first use in this function)
net/ipv6/ip6mr.c:360: error: dereferencing pointer to incomplete type
net/ipv6/ip6mr.c:366: error: dereferencing pointer to incomplete type
net/ipv6/ip6mr.c:370: error: dereferencing pointer to incomplete type
make[2]: *** [net/ipv6/ip6mr.o] Error 1

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
