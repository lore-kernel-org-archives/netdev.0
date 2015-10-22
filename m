From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 12:58:49 +0100
Message-ID: <5628CF79.2000507@oracle.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk>	 <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk>	 <20151021.182955.1434243485706993231.davem@davemloft.net>	 <5628636E.1020107@oracle.com>	  <201510220615.t9M6FL2d017592@room101.nl.oracle.com> <1445513425.22974.100.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, viro@ZenIV.linux.org.uk,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Eric Dumazet <eric.dumazet@gmail.com>, Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46217 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbbJVL7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 07:59:05 -0400
In-Reply-To: <1445513425.22974.100.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/10/2015 12:30, Eric Dumazet wrote:

> We absolutely do not _want_ to do this just so that linux becomes slower
> to the point Solaris can compete, or you guys can avoid some work.

Sentiments such as that really have no place in a discussion that's been 
focussed primarily on the behaviour of interfaces, albeit with 
digressions into the potential performance impacts. The discussion has 
been cordial and I for one appreciate Al Viro's posts on the subject, 
from which I've leaned a lot. Can we please keep it that way? Thanks.

> close(fd) is very far from knowing a file is a 'listener' or even a
> 'socket' without extra cache line misses.
>
> To force a close of an accept() or whatever blocking socket related
> system call a shutdown() makes a lot of sense.
>
> This would have zero additional overhead for the fast path.

Yes, that would I believe be a significant improvement.

-- 
Alan Burlison
--
