From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ep93xx-eth: convert to phylib
Date: Sun, 05 Jun 2011 14:06:57 -0700 (PDT)
Message-ID: <20110605.140657.1039864716002412071.davem@davemloft.net>
References: <201106051957.36492.florian@openwrt.org>
	<201106052029.24742.f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hvr@gnu.org, kernel@wantstofly.org,
	mika.westerberg@iki.fi, hsweeten@visionengravers.com,
	ryan@bluewatersys.com, linux-arm-kernel@lists.infradead.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab1FEVIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:08:19 -0400
In-Reply-To: <201106052029.24742.f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sun, 5 Jun 2011 20:29:24 +0200

> On Sunday 05 June 2011 19:57:36 Florian Fainelli wrote:
>> ep93xx-eth lacked support for monitoring link status changes, with this
>> patch, link changes are now watched and reported correctly.
>> 
>> Signed-off-by: Florian Fainelli <florian@openwrt.org>
>> ---
> 
> I just stumbled upon: http://www.mail-
> archive.com/netdev@vger.kernel.org/msg62549.html
> which does not seem to have been merged.
> 
> I will respin my patch with Herbert's changes

If people wonder why things don't get merged in situations like
this it's because there is no clear person standing up to act as
a maintainer.

Instead there are several different people submitting changes to
this one driver and I haven't got a clue who is authoritative and
who is not.

So 9 times out of ten I'm not going to merge anything submitted
in this way unless I start to see lots of ACKs from other developers.

When it gets to the point where multiple people are touching the
driver in all sorts of ways, there needs to be someone to do all of
the merging and making sure the patches get applied in the right order
and handling merge conflicts handled properly.  Then they submit them
formally here as a sane single set of patches to the list.

So who is going to step up and be the ep93xx-eth maintainer?  Lennert
is listed in MAINTAINERS, but I see little to no activity from him.

The last ACK Lennert gave for a patch to this driver was in May 2010,
more than a year ago.
