From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 23 Oct 2015 16:46:05 +0100
Message-ID: <562A563D.6020600@oracle.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk>	 <20151021.182955.1434243485706993231.davem@davemloft.net>	 <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk>	 <20151022060304.GQ22011@ZenIV.linux.org.uk>	 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>	 <20151022172146.GS22011@ZenIV.linux.org.uk>	 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>	 <20151022190701.GV22011@ZenIV.linux.org.uk>	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>	 <20151022215741.GW22011@ZenIV.linux.org.uk>	 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>	 <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>	 <562A37A3.8000705@oracle.com> <1445610118.22974.153.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43367 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbbJWPqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 11:46:16 -0400
In-Reply-To: <1445610118.22974.153.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/10/2015 15:21, Eric Dumazet wrote:

> I claim nothing. If you believe a man page should be fixed, please send
> a patch to man page maintainer.

Ermm, you *really* want me to submit a patch removing 'Conforms to 
POSIX.1-2001' from *every* Linux manpage?

> Have you tested the patch I sent ?

The AF_UNIX poll one? No, I don't have the means to do so, and in any 
case that's not a POSIX issue, just a plain bug. I'm happy to log a bug 
if that helps.

> The goal here is to improve things, not to say you are right or I am
> right. I am very often wrong, then what ?
>
> This list is about linux kernel development.

Thank you for the clarification.

-- 
Alan Burlison
--
