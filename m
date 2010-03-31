From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 04/12] l2tp: Add ppp device name to L2TP ppp session
 data
Date: Wed, 31 Mar 2010 01:46:31 -0700 (PDT)
Message-ID: <20100331.014631.65794997.davem@davemloft.net>
References: <20100330161746.9628.40723.stgit@bert.katalix.com>
	<20100330092914.4f3e9ed3@nehalam>
	<4BB2FD0D.1080105@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57110
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932711Ab0CaIqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 04:46:31 -0400
In-Reply-To: <4BB2FD0D.1080105@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Wed, 31 Mar 2010 08:43:09 +0100

> Stephen Hemminger wrote:
>> On Tue, 30 Mar 2010 17:17:46 +0100
>> James Chapman <jchapman@katalix.com> wrote:
>> 
>>> When dumping L2TP PPP sessions using /proc/net/l2tp, get
>>> the assigned PPP device name from PPP using ppp_dev_name().
>>>
>>> Signed-off-by: James Chapman <jchapman@katalix.com>
>>> Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>
>>>
>> 
>> Why is this a necessary API?
>> Why not put it in debugfs if just a debugging tool?
> 
> With the original driver (merged in 2.6.23), some people use horrible
> hacks in scripts to derive info about their L2TP connections from /proc.
> So I was reluctant to move it to debugfs in the new driver. If it is ok
> to move an existing /proc file to debugfs, I'm happy to do so. People
> should obtain such info from their L2TP userspace daemon, or through
> netlink anyway.

Existing stuff you shouldn't move around, people do depend on it
and thus it has to be retained.

But for new stuff, we can try to think about better ways to export the
information if possible.
