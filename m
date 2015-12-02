From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: ipsec impact on performance
Date: Wed, 2 Dec 2015 17:08:03 -0500
Message-ID: <20151202220803.GG15262@oracle.com>
References: <20151201183720.GE21252@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
 <20151202121156.GK23178@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE0F39@AcuExch.aculab.com>
 <20151202205028.GB15262@oracle.com>
 <CALx6S34yqw_vJ+r21Br9O7y5NqzvA264ot7=GBTHe=FxWqh=AQ@mail.gmail.com>
 <20151202211201.GD15262@oracle.com>
 <CALx6S36gcbJRJOTdUhgZGVbe4YzBeuBgv105kXLMyDSBBQ_56Q@mail.gmail.com>
 <20151202214708.GF15262@oracle.com>
 <CALx6S34bCaL1PRfFgiPuj8d7m6EvbfzebtAHpN=QkKMuTgO9Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@aculab.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	Rick Jones <rick.jones2@hpe.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25951 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756384AbbLBWIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 17:08:16 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S34bCaL1PRfFgiPuj8d7m6EvbfzebtAHpN=QkKMuTgO9Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/02/15 14:01), Tom Herbert wrote:
> No, please don't persist is this myopic "we'll get to IPv6 later"
> model! IPv6 is a real protocol, it has significant deployment of the
> Internet, and there are now whole data centers that are IPv6 only
> (e.g. FB), and there are plenty of use cases of IPSEC/IPv6 that could
> benefit for performance improvements just as much IPv4. This vendor
> mentality that IPv6 is still not important simply doesn't help
> matters. :-(

Ok, I'll get you the numbers for this later, and sure, if we do
this, we should solve the ipv6 problem too.

BTW, the ipv6 nov3 paths have severe alignment issues. I flagged
this a long time ago http://www.spinics.net/lists/netdev/msg336257.html

I think all of it is triggered by mld. Someone needs to do
something about that too. I dont think those paths are using 
NET_ALIGN very well, and I dont think this is the most wholesome
thing for perf.

--Sowmini
