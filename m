From: David Miller <davem@davemloft.net>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Tue, 01 Aug 2006 14:54:34 -0700 (PDT)
Message-ID: <20060801.145434.25473901.davem@davemloft.net>
References: <20060730113050.GL8334@innerghost.net>
	<20060731.142307.35014994.davem@davemloft.net>
	<20060801115002.GX8334@innerghost.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, hadi@cyberus.ca, shemminger@osdl.org,
	herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27783
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750948AbWHAVyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 17:54:33 -0400
To: hsantos@av.it.pt
In-Reply-To: <20060801115002.GX8334@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hugo Santos <hsantos@av.it.pt>
Date: Tue, 1 Aug 2006 12:50:02 +0100

>    I might have some cycles during the month to code up something in
>  this direction, at least for an initial review, i'll try to do so.

Great.  I prefer to talk about code anyways :)

>    Also, the reliability of a system depends on a lot of things, but
>  please, let's not use the assumption that because everything sits in
>  the kernel, it will be stable as the number of 'points of failure' is
>  smaller; this is only true as long as people work to have stable
>  components -- and this is independent of where the components sit.

This disagrees with my experience.  Things in the kernel tend to get
noticed fast and fixed, whereas things in userspace can stay broken
for a long period of time.

Everything is about momentum, and the kernel is where all the
development momentum is.  It's not in these userland components.

People are running semantic checkers on the kernel constantly,
the kernel has all sorts of automatic locking, memory allocation,
et. al verifications and assertions.

A particular userland components might have this treatment and checks,
but the kernel has them going all the time and people are looking at
the output of these tools and checks constantly.  You cannot get the
kind of coverage the kernel gets.

As Andrew Morton says, userland is just a testsuite for the kernel.
:-)
