From: David Miller <davem@davemloft.net>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 03 Aug 2010 00:18:09 -0700 (PDT)
Message-ID: <20100803.001809.25133218.davem@davemloft.net>
References: <20100802110334.GK11110@cel.leo>
	<20100802.221341.137851732.davem@davemloft.net>
	<20100803070426.GN11110@cel.leo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leonerd@leonerd.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59594
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755367Ab0HCHRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 03:17:51 -0400
In-Reply-To: <20100803070426.GN11110@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Date: Tue, 3 Aug 2010 08:04:27 +0100

> On Mon, Aug 02, 2010 at 10:13:41PM -0700, David Miller wrote:
>> > Any comments on this, while I proceed? Barring any major complaints,
>> > I'll have a hack at some code and present a patch in due course...
>> 
>> We're not adding loop instructions, it's just asking for trouble
>> since any user can attach BPF filters to a socket and it's just
>> way too easy to make a loop endless.
>> 
>> There's a reason no loop primitives were added to the original
>> BPF specification, perhaps you should take a look at what their
>> reasoning was.
> 
> Yes. I am very aware of that.
> 
> Please read carefully my suggestion. These loops cannot be made endless
> - they will be bounded by, at most, the number of bytes in the packet
> buffer. The loop is required to increment X at least 1 at every
> iteration, and will not allow it to continue past the end of the packet.
> This puts a strict bound on the runtime of the loop.

That makes the looping construct largely useless, which I mentioned in
my second reply to this thread.

