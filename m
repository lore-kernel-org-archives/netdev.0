From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 23 Oct 2015 07:21:58 -0700
Message-ID: <1445610118.22974.153.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk>
	 <20151021.182955.1434243485706993231.davem@davemloft.net>
	 <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk>
	 <20151022060304.GQ22011@ZenIV.linux.org.uk>
	 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
	 <20151022172146.GS22011@ZenIV.linux.org.uk>
	 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
	 <20151022190701.GV22011@ZenIV.linux.org.uk>
	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
	 <20151022215741.GW22011@ZenIV.linux.org.uk>
	 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
	 <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562A37A3.8000705@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33833 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbbJWOWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 10:22:02 -0400
Received: by padhk11 with SMTP id hk11so119983692pad.1
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 07:22:01 -0700 (PDT)
In-Reply-To: <562A37A3.8000705@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-23 at 14:35 +0100, Alan Burlison wrote:

> If you think it's a POSIX deficiency then logging a DR is probably the 
> correct way of addressing that. And as I've said it's fine to decide 
> that you don't care about what POSIX says on the subject but you can't 
> simultaneously claim POSIX conformance. One or the other, not both.

I claim nothing. If you believe a man page should be fixed, please send
a patch to man page maintainer.

Have you tested the patch I sent ?

The goal here is to improve things, not to say you are right or I am
right. I am very often wrong, then what ?

This list is about linux kernel development.
