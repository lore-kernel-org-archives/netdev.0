From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smsc911x: fix RX FIFO fastforwarding when
 dropping packets
Date: Fri, 13 Apr 2012 14:08:25 -0400 (EDT)
Message-ID: <20120413.140825.574220698055703201.davem@davemloft.net>
References: <20120412155409.GA28204@mudshark.cambridge.arm.com>
	<1334246880.5300.6736.camel@edumazet-glaptop>
	<20120412170350.GD28204@mudshark.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	steve.glendinning@smsc.com
To: will.deacon@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51337 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311Ab2DMSIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 14:08:35 -0400
In-Reply-To: <20120412170350.GD28204@mudshark.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Will Deacon <will.deacon@arm.com>
Date: Thu, 12 Apr 2012 18:03:50 +0100

> On Thu, Apr 12, 2012 at 05:08:00PM +0100, Eric Dumazet wrote:
>> On Thu, 2012-04-12 at 16:54 +0100, Will Deacon wrote:
>> >     net: smsc911x: fix skb handling in receive path
>> >     
>> >     The SMSC911x driver resets the ->head, ->data and ->tail pointers in the
>> >     skb on the reset path in order to avoid buffer overflow due to packet
>> >     padding performed by the hardware.
>> >     
>> >     This patch fixes the receive path so that the skb pointers are fixed up
>> >     after the data has been read from the device, The error path is also
>> >     fixed to use number of words consistently and prevent erroneous FIFO
>> >     fastforwarding when skipping over bad data.
>> >     
>> >     Signed-off-by: Will Deacon <will.deacon@arm.com>
> 
> [...]
> 
>> Seems fine to me
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Thanks, Eric. Given that Steve's email doesn't appear to be working, can
> somebody else pick this up please?

Applied, thanks.
