From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: ipv6: why disable ipv6 on last address removal?
Date: Wed, 09 Dec 2009 16:39:15 +0900
Message-ID: <4B1F5423.4070109@linux-ipv6.org>
References: <20091208192046.GA5649@midget.suse.cz> <20091208.125611.135547597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39364 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752016AbZLIHjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 02:39:21 -0500
In-Reply-To: <20091208.125611.135547597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Well, AFAIK, it is basically ancient thing.
Some (rather new) paramters are exactly related bringing
up each interface.

Such parameters should be set _before_ it is brought up.
For now, people can do this using the "default" value.

We might have rtnetlink interface for up/down interface,
allowing userspace to send related parameters as well.

Regards,

--yoshfuji

David Miller wrote:
> From: Jiri Bohac <jbohac@suse.cz>
> Date: Tue, 8 Dec 2009 20:20:46 +0100
> 
>> Is there any reason why inet6_addr_del needs to sets how=1 and
>> disable IPv6 even more than "ifconfig down" does?
> 
> All I can say is that this behavior is definitely on purpose, although
> I don't exactly remember why.
> 
> And although it helps you, it could also break things for other people
> who expect the current behavior.
> 
> Some people definitely expect no IPV6 at all in any way shape or
> form if they have not assigned IPV6 addresses to an interface.

