From: David Miller <davem@davemloft.net>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 03 Aug 2010 06:07:54 -0700 (PDT)
Message-ID: <20100803.060754.26959298.davem@davemloft.net>
References: <20100803070426.GN11110@cel.leo>
	<20100803.001809.25133218.davem@davemloft.net>
	<87mxt3etut.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leonerd@leonerd.org.uk, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53042
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752983Ab0HCNHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 09:07:36 -0400
In-Reply-To: <87mxt3etut.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 03 Aug 2010 14:58:02 +0200

> David Miller <davem@davemloft.net> writes:
>>
>> That makes the looping construct largely useless, which I mentioned in
>> my second reply to this thread.
> 
> How about simply adding a "skip ipv6 extension headers until header type
> X" opcode?
> 
> I bet that would solve most of the problems here in practice.

BPF really should not have protocol specific opcodes.
