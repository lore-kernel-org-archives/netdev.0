From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net: Add etun driver
Date: Mon, 09 Apr 2007 11:48:07 -0700
Message-ID: <461A8A67.6030103@candelatech.com>
References: <1176136628.8459.34.camel@johannes.berg>	<461A70A5.8060607@trash.net>	<461A829C.7050703@candelatech.com> <20070409.113730.71114683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net, ebiederm@xmission.com,
	shemminger@linux-foundation.org, jgarzik@pobox.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, dlezcano@fr.ibm.com, dim@openvz.org,
	containers@lists.osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:48345 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753412AbXDISs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2007 14:48:59 -0400
In-Reply-To: <20070409.113730.71114683.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Mon, 09 Apr 2007 11:14:52 -0700
> 
>> Patrick McHardy wrote:
>>
>>> It would be nice if someone would finally come up with a generic
>>> interface based on netlink (RTM_NEWLINK) instead of adding yet
>>> another couple of homegrown interfaces.
>> My preference is for ioctls, procfs, or similar that does not
>> require extra libraries.  Ethtool is an ioctl based approach,
>> so that could potentially be used, though I'm not sure if
>> that's the right place to put it...
> 
> I totally disagree.
> 
> Netlink doesn't require libraries, the libraries just make using it
> easier.  It's a simple protocol sent over a socket, if you include
> the right headers you can do it all yourself.
> 
> We shouldn't fail to use our proper core network configuration
> interface just because it's inconvenient for you.

Well, I find it inconvenient, so my preference is for other
methods...that shouldn't be too supprising.  I'm a lazy programmer
after all! :)

If it does get added, and something like 'ip' gains ability to
use it, then I can just system("ip whatever"), so maybe that's the
out for lazy programmers...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

