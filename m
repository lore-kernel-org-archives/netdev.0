From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 3 Aug 2010 16:05:39 +0200
Message-ID: <20100803140539.GE31096@basil.fritz.box>
References: <20100803070426.GN11110@cel.leo>
 <20100803.001809.25133218.davem@davemloft.net>
 <87mxt3etut.fsf@basil.nowhere.org>
 <20100803.060754.26959298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, leonerd@leonerd.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39618 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755500Ab0HCOFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 10:05:44 -0400
Content-Disposition: inline
In-Reply-To: <20100803.060754.26959298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 03, 2010 at 06:07:54AM -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 03 Aug 2010 14:58:02 +0200
> 
> > David Miller <davem@davemloft.net> writes:
> >>
> >> That makes the looping construct largely useless, which I mentioned in
> >> my second reply to this thread.
> > 
> > How about simply adding a "skip ipv6 extension headers until header type
> > X" opcode?
> > 
> > I bet that would solve most of the problems here in practice.
> 
> BPF really should not have protocol specific opcodes.

Well you could generalize it, like "SKIP headers where length 
is at offset X and type at offset Y" 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
