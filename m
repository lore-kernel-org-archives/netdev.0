From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Fri, 19 Mar 2010 18:18:36 +0100
Message-ID: <87tysccjrn.fsf@basil.nowhere.org>
References: <alpine.DEB.2.00.1003181245050.23010@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1003181245050.23010@router.home> (Christoph Lameter's message of "Thu, 18 Mar 2010 12:58:48 -0500 (CDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <cl@linux-foundation.org> writes:
>
> I know about the openpgm implementation. Openpbm does this at the user
> level and requires linking to a library. It is essentially a communication
> protocol done in user space. It has privilege issues because it has to
> create PGM packets via a raw socket.

That seems like a poor reason alone to put something into the kernel
Perhaps you rather need some way to have unpriviledged raw sockets?

The classical way to do this is to start suid root, only open
the socket and then drop privileges.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
