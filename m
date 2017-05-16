From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Tue, 16 May 2017 18:35:39 +0200
Message-ID: <20170516163539.GA5491@lst.de>
References: <1494950224.3259.98.camel@redhat.com> <20170516.122923.869994491617365845.davem@davemloft.net> <20170516163041.GA5132@lst.de> <20170516.123308.2059131411772131424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, dledford@redhat.com, Bart.VanAssche@sandisk.com,
        torvalds@linux-foundation.org, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, stable@vger.kernel.org,
        ubraun@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170516.123308.2059131411772131424.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2017 at 12:33:08PM -0400, David Miller wrote:
> That doesn't cover things that don't directly touch the RDMA code or
> infiniband infrastructure.
> 
> There should have been RDMA people on netdev who saw this thing and
> cried wolf, and they would have had about an entire year, and about
> 8 instances of this series being posted in which to do so.
> 
> It's not like this got posted once or twice and went in with zero
> review.

None outside of netdev.  Really, if you get rdma patches include
linux-rdma.  Or at least linux-kernel where I will usually catch
this sort of stuff.  netdev is too high traffic and too far away
from my area of work to watch it.

But for example when I wrote my first RDMA ULP I did subsribe
to linux-rdma, started extensive discussions and fixed up lots
of core code.  There is no excuse for other people to not even
try.
