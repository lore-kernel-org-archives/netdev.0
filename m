From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Fri, 06 Jan 2012 17:50:28 -0800 (PST)
Message-ID: <20120106.175028.1076280359661712542.davem@davemloft.net>
References: <20120105.192833.760673635385506638.davem@davemloft.net>
	<CA+55aFyk6QJib8UCtK_gWzidr8Ti1utJgHg359fkq=+GY8hbnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759389Ab2AGBue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 20:50:34 -0500
In-Reply-To: <CA+55aFyk6QJib8UCtK_gWzidr8Ti1utJgHg359fkq=+GY8hbnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 6 Jan 2012 17:34:39 -0800

> On Thu, Jan 5, 2012 at 4:28 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Netlink socket dumping is now supported for UDP and AF_UNIX sockets
>> thanks to Pavel Emelyanov.
> 
> .. and this is such a magically important feature that it has to be
> enabled by default?
> 
> It's something that has never been supported before, how did it
> suddenly become 'default y' after twenty years of not even being an
> issue?

Netlink socket dumping has been enabled on every kernel for the past
10 years.  It's just been made to work for things other than TCP
and DCCP.

It replaces the crappy and hard to scale procfs socket listing junk,
which doesn't even provide a way to filter requests.
