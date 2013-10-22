From: David Miller <davem@davemloft.net>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Tue, 22 Oct 2013 15:46:38 -0400 (EDT)
Message-ID: <20131022.154638.1989281525248160764.davem@davemloft.net>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
	<20131001222002.GL10771@order.stressinduktion.org>
	<3928724.bDaZagpRh6@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: linux@stwm.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038Ab3JVTqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 15:46:40 -0400
In-Reply-To: <3928724.bDaZagpRh6@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Walter <linux@stwm.de>
Date: Tue, 22 Oct 2013 21:07:41 +0200

> Am Mittwoch, 2. Oktober 2013, 00:20:02 schrieb Hannes Frederic Sowa:
>> On Tue, Oct 01, 2013 at 06:39:32PM +0200, Wolfgang Walter wrote:
>> > All network traffic over the router become slow and sluggish. If one pings
>> > the router there is a packet loss. After about 2 minutes the traffic
>> > completely stalls for about 1 minute. Then it works again as in the
>> > beginning to then stall again. And so on.
>> 
>> Maybe dropwatch can give a first hint?
>> 
> 
> I finally found the problem:
> 
> In 3.10.x and 3.11.x the value of /proc/sys/net/ipv4/xfrm4_gc_thresh is 1024.
> 
> It is much higher in 3.4.x. If I increase this value in 3.10.x to the one I 
> see on 3.4.x all works fine with 3.10.x

Steffen, here is yet another report about this issue.

I think we should resolve this soon, even bumping it to 2048 or 4096
and leaving it at that would be I think acceptable.

Thanks.
