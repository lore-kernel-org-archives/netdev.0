From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: separate out procfs code from mcast.c
Date: Tue, 23 Apr 2013 03:18:05 -0400 (EDT)
Message-ID: <20130423.031805.544535198246859192.davem@davemloft.net>
References: <1366700820-26052-1-git-send-email-amwang@redhat.com>
	<20130423.031135.166163672665280174.davem@davemloft.net>
	<1366701302.21136.19.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304Ab3DWHSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 03:18:07 -0400
In-Reply-To: <1366701302.21136.19.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 23 Apr 2013 15:15:02 +0800

> On Tue, 2013-04-23 at 03:11 -0400, David Miller wrote:
>> From: Cong Wang <amwang@redhat.com>
>> Date: Tue, 23 Apr 2013 15:07:00 +0800
>> 
>> > From: Cong Wang <amwang@redhat.com>
>> > 
>> > They well deserve a separated unit.
>> > 
>> > Cc: "David S. Miller" <davem@davemloft.net>
>> > Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org> 
>> > Signed-off-by: Cong Wang <amwang@redhat.com>
>> 
>> Cong, I'm not even reading these patches.
>> 
>> You're on this idea that you can just keep the sysfs and procfs bits
>> of ipv6 modular, and make the rest of ipv6 statically linked into the
>> kernel.
> 
> I am trying that only for mcast.c, not for the whole IPv6.

The multicast stuff does route lookups, how are you going to
accomplish this?

Besides you should move the statically-needed code into a new
file (mcast_core.c or something like that, following the existing
model and conventions for doing this) rather than the other way
around.

And that patch should be posted in a series with the user that
needs this (your vxlan ipv6 patches), not by itself.
