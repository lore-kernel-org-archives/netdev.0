From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: ip6_pkt_prohibit(_out) should not depend on
 CONFIG_IPV6_MULTIPLE_TABLES
Date: Sat, 30 Nov 2013 12:51:10 -0500 (EST)
Message-ID: <20131130.125110.248139896351909341.davem@davemloft.net>
References: <20131128190411.GD24171@order.stressinduktion.org>
	<20131129.163930.203685593163996122.davem@davemloft.net>
	<20131130174635.GK24171@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kamala@aristanetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131130174635.GK24171@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 30 Nov 2013 18:46:35 +0100

> On Fri, Nov 29, 2013 at 04:39:30PM -0500, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Thu, 28 Nov 2013 20:04:11 +0100
>> 
>> > Since patch "IPv6: Fixed support for blackhole and prohibit routes" we
>> > need ip6_pkt_prohibit(_out) available without CONFIG_IPV6_MULTIPLE_TABLES
>> > defined.
>> > 
>> > Cc: Kamala R <kamala@aristanetworks.com>
>> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> 
>> Please reference the SHA1 ID of the change as well as it's commit
>> header text, thank you.
> 
> This patch is a follow-up patch for the first one in this thread which is not
> committed, yet. Either Kamala can squash them into one or I'll repost it
> later.

I think they need to be combined, otherwise bisection is broken.
