From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 23 Oct 2015 14:35:31 +0100
Message-ID: <562A37A3.8000705@oracle.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk>	 <20151021.182955.1434243485706993231.davem@davemloft.net>	 <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk>	 <20151022060304.GQ22011@ZenIV.linux.org.uk>	 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>	 <20151022172146.GS22011@ZenIV.linux.org.uk>	 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>	 <20151022190701.GV22011@ZenIV.linux.org.uk>	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>	 <20151022215741.GW22011@ZenIV.linux.org.uk>	  <201510230952.t9N9qYZJ021998@room101.nl.oracle.com> <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Eric Dumazet <eric.dumazet@gmail.com>, Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26325 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbbJWNfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:35:42 -0400
In-Reply-To: <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/10/2015 14:02, Eric Dumazet wrote:

>> Other data is used to make sure that it only takes O(log(n)) to find the
>> lowest available file descriptor entry.  (Where n, I think, is the returned
>> descriptor)
>
> Yet another POSIX deficiency.
>
> When a server deals with 10,000,000+ socks, we absolutely do not care of
> this requirement.
>
> O(log(n)) is still crazy if it involves O(log(n)) cache misses.

If you think it's a POSIX deficiency then logging a DR is probably the 
correct way of addressing that. And as I've said it's fine to decide 
that you don't care about what POSIX says on the subject but you can't 
simultaneously claim POSIX conformance. One or the other, not both.

-- 
Alan Burlison
--
