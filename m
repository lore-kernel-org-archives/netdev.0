From: Andi Kleen <ak@muc.de>
Subject: Re: Mystery packet killing tg3
Date: 5 May 2005 13:43:27 +0200
Message-ID: <20050505114327.GA51761@muc.de>
References: <20050502162405.65dfb4a9@localhost.localdomain> <20050502200251.38271b61.davem@davemloft.net> <m14qdiyhcn.fsf@muc.de> <42791825.2080204@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 5 May 2005 13:43:27 +0200
To: Peter Buckingham <peter@pantasys.com>
Content-Disposition: inline
In-Reply-To: <42791825.2080204@pantasys.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> >IOMMU code on x86-64 should be never active unless Stephen
> >used IOMMU_DEBUG or iommu=force.  THat is because the tg3
> >is a 64bit capable device and should always use bypass.
> 
> how is this detected? we have a board that is using a 32bit e1000 and we 
> have to use iommu=force otherwise it doesn't do the right thing with > 
> 4GB of RAM.

"32bit e1000"? How did you get such a beast? AFAIK all e1000s are 64bit
address capable. Please supply a full boot log without iommu=force 
and describe what happens exactly.



-Andi
