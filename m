From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 2/2] unix: Add /proc/net/unix_peers file
Date: Mon, 05 Dec 2011 14:25:11 +0400
Message-ID: <4EDC9C07.6070904@parallels.com>
References: <4ED7BC37.2030805@parallels.com>	<4ED7BC6E.3040600@parallels.com> <20111204.132510.1708510157080644595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32695 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754519Ab1LEKZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 05:25:20 -0500
In-Reply-To: <20111204.132510.1708510157080644595.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2011 10:25 PM, David Miller wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> Date: Thu, 01 Dec 2011 21:42:06 +0400
> 
>> Currently it's not possible to find out what processes are connected
>> to each other via a unix socket. In the proposed proc file a socket
>> inode number and its peer inode number are shown. With these two at
>> hands it's possible to determine the unix connections endpoints.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> I'm basically against new networking procfs based information
> retrieval mechanisms.

So am I, just wanted to bring this topic up again.

> Please extend the netlink socket dumping so that it works with
> AF_UNIX sockets and subsequently added the necessary netlink
> attribute to provide the peer value.

OK, will do it this way. AFAIU you're talking about the NETLINK_INET_DIAG, right?

> I plan to stand pretty firm on this, so you may want to save your
> effort and use said effort to implement this properly.
> 
> Thanks.
> .
> 

Thanks,
Pavel
