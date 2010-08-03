From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 03 Aug 2010 14:58:02 +0200
Message-ID: <87mxt3etut.fsf@basil.nowhere.org>
References: <20100802110334.GK11110@cel.leo>
	<20100802.221341.137851732.davem@davemloft.net>
	<20100803070426.GN11110@cel.leo>
	<20100803.001809.25133218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: leonerd@leonerd.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39712 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756289Ab0HCM6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 08:58:08 -0400
In-Reply-To: <20100803.001809.25133218.davem@davemloft.net> (David Miller's
	message of "Tue, 03 Aug 2010 00:18:09 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
>
> That makes the looping construct largely useless, which I mentioned in
> my second reply to this thread.

How about simply adding a "skip ipv6 extension headers until header type
X" opcode?

I bet that would solve most of the problems here in practice.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
