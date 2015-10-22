From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 14:14:42 +0100
Message-ID: <5628E142.7050600@oracle.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk>	 <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk>	 <20151021.182955.1434243485706993231.davem@davemloft.net>	 <5628636E.1020107@oracle.com>	 <201510220615.t9M6FL2d017592@room101.nl.oracle.com>	 <1445513425.22974.100.camel@edumazet-glaptop2.roam.corp.google.com>	 <5628CF79.2000507@oracle.com> <1445515858.22974.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, David Miller <davem@davemloft.net>,
	viro@ZenIV.linux.org.uk, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21128 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbbJVNOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 09:14:52 -0400
In-Reply-To: <1445515858.22974.113.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/10/2015 13:10, Eric Dumazet wrote:

>> Sentiments such as that really have no place in a discussion that's been
>> focussed primarily on the behaviour of interfaces, albeit with
>> digressions into the potential performance impacts. The discussion has
>> been cordial and I for one appreciate Al Viro's posts on the subject,
>> from which I've leaned a lot. Can we please keep it that way? Thanks.
>
> Certainly not.

OK, in  which case I'll make this my last on-list reply to this part of 
the thread as I think continuing it is unlikely to be productive. If you 
would like to further discuss your concerns about my motivations I'm 
happy to do so off list, along with anyone you want to cc in. Thanks.

> I am a major linux networking developper and wont accept linux is
> hijacked by guys who never contributed to it, just so it meets their
> unreasonable expectations.

Yes, I'm aware of who you are. And if my expectations were completely 
unreasonable then I'd have expected the conversation to have already 
drawn to a close by now.

> We absolutely care about performance. And I do not care you focus on
> POSIX crap.

Yes, I understand the concern about the potential performance impact and 
it's a valid concern. And I also understand that the current Linux 
behaviour of shutdown() on unconnected sockets probably can't be changed 
without causing breakage and is therefore unlikely to happen as well.

The issues I hit were in the context of application porting, where the 
APIs in question are covered by POSIX. The Linux manpages for open(), 
close(), socket(), dup2() and shutdown() all claim POSIX.1-2001 
conformance. If performance is the most important concern then it's a 
valid decision to prioritise that over POSIX conformance, you simply 
can't continue to claim that the relevant Linux APIs are fully POSIX 
conformant, so I believe at the minimum the Linux manpages need modifying.

-- 
Alan Burlison
--
