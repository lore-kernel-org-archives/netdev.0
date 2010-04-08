From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v3 0/4] xfrm: add x86 CONFIG_COMPAT support
Date: Thu, 08 Apr 2010 13:24:17 +0200
Message-ID: <4BBDBCE1.7090003@trash.net>
References: <4BBC8C8F.9020907@trash.net>	<20100407.164842.54065324.davem@davemloft.net>	<4BBDA58B.8090301@trash.net> <20100408.025412.247148013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, johannes@sipsolutions.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35289 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758227Ab0DHLYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 07:24:19 -0400
In-Reply-To: <20100408.025412.247148013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 08 Apr 2010 11:44:43 +0200
> 
>> Either the kernel or the userspace programs have to be updated
>> either way.
> 
> The only case in which we only have to change one side is if we add
> the full set of compat support to the kernel.
> 
> If we take any other option (new XFRM numbers and new datastructures,
> or only convert sendmsg() to do compat translations), it requires both
> the kernel and userspace to change.

You're right of course.

> And the currently existing 32-bit binaries don't work on 64-bit
> kernels because of something that cannot be classified any other way
> than as being a kernel bug.

Agreed, but since its not a new bug, I think we have some flexibility
in how to fix it. In the wireless case we had no real choice but to
add the COMPAT_NETLINK thing, but its a bit sad to add more of this
crap to netlink.

Anyways, I guess there's no reason why we couldn't do both and
transistion to a fixed API in the long term.
