From: Patrick McHardy <kaber@trash.net>
Subject: Re: gre: minor cleanups in netlink interface
Date: Sat, 11 Oct 2008 17:39:36 +0200
Message-ID: <48F0C8B8.7010400@trash.net>
References: <48EF7D24.6040400@trash.net> <20081011103935.GA6168@gondor.apana.org.au> <48F0BB77.6080401@trash.net> <48F0BC1C.5020005@trash.net> <20081011151820.GB7520@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52852 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753966AbYJKPjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 11:39:41 -0400
In-Reply-To: <20081011151820.GB7520@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Oct 11, 2008 at 04:45:48PM +0200, Patrick McHardy wrote:
>> Its actually also what defines the difference between using
>> NLM_F_REPLACE (ip link replace) and no flags (ip link change).
>> The former replaces the replaces the object, the later changes
>> an existing object.
> 
> That wasn't the case historically.  For routing NLM_F_REPLACE
> had a real meaning because you can have routes that differ only
> by scope.  So if you considered routes that are otherwise the
> same to be duplicate routes, then NLM_F_REPLACE tells you whether
> you're allowed to create a new route or you must modify one
> of the existing ones.  Of course completely duplicate routes
> where everything is equal is not allowed.

Interesting, I wasn't aware of that.

> Of course NLM_F_REPLACE has since been seconded for other purposes
> so I suppose it can mean whatever you want for rtnl link :)

It actually not supported currently because replacement of links
(while keeping routes etc.) would be highly complicated.
