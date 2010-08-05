From: lkml20100708@newton.leun.net
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free
 (adding ipv6 address to interface)
Date: Fri, 6 Aug 2010 01:45:26 +0200
Message-ID: <20100806014526.42ffda09@xenia.leun.net>
References: <m1y6clz8ta.fsf_-_@fess.ebiederm.org>
	<20100805134707.0442a7b1@xenia.leun.net>
	<m1bp9g7ry0.fsf@fess.ebiederm.org>
	<20100805.131128.42817872.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, greg@kroah.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, adobriyan@gmail.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv04.lahn.de ([213.239.197.57]:42807 "EHLO serv04.lahn.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758633Ab0HEXtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 19:49:15 -0400
In-Reply-To: <20100805.131128.42817872.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 05 Aug 2010 13:11:28 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 05 Aug 2010 12:57:59 -0700
> 
> > I wonder what has changed with ipv6 recently.
> 
> There was a recent fix to the IGMP snooping code we have in
> the bridging layer, if parsing of an ipv6 IGMP packet failed
> we'd leak the packet (and thus references to whatever device
> it referenced).
> 
> commit 6d1d1d398cb7db7a12c5d652d50f85355345234f
[...]

But this patch is not in 2.6.35 and therefore cannot make the
difference Eric sees (belives to see) between his modified 2.6.32 and
2.6.35.

Also, this patch, if I understand that correctly, only changes bridging
and in my scenario bridge.ko (have it as module) was not even loaded,
so applying this patch should not make any difference for the bug I
see, or do I overlook something?

So, I guess, your answer was general information to Erics question what
changed with ipv6, not related to that bug we seek in particular?

-- 
MfG,

Michael Leun

