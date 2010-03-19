From: David Miller <davem@davemloft.net>
Subject: Re: Add PGM protocol support to the IP stack
Date: Fri, 19 Mar 2010 14:53:36 -0700 (PDT)
Message-ID: <20100319.145336.226782717.davem@davemloft.net>
References: <alpine.DEB.2.00.1003181245050.23010@router.home>
	<87tysccjrn.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87tysccjrn.fsf@basil.nowhere.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 19 Mar 2010 18:18:36 +0100

> Christoph Lameter <cl@linux-foundation.org> writes:
>>
>> I know about the openpgm implementation. Openpbm does this at the user
>> level and requires linking to a library. It is essentially a communication
>> protocol done in user space. It has privilege issues because it has to
>> create PGM packets via a raw socket.
> 
> That seems like a poor reason alone to put something into the kernel
> Perhaps you rather need some way to have unpriviledged raw sockets?
> 
> The classical way to do this is to start suid root, only open
> the socket and then drop privileges.

I completely agree.

We should be able to make a way for unprivileged users to
use RAW sockets in some limited capacity, for cases like this.

But I also don't consider what openpbm has to do right now to
be all that much of a restriction.  You need privileges to
add the protocol to the kernel, you need privileges to run
the userspace variant, there is no real difference.
