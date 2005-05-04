From: Peter Buckingham <peter@pantasys.com>
Subject: Re: Mystery packet killing tg3
Date: Wed, 04 May 2005 11:44:53 -0700
Message-ID: <42791825.2080204@pantasys.com>
References: <20050502162405.65dfb4a9@localhost.localdomain>	<20050502200251.38271b61.davem@davemloft.net> <m14qdiyhcn.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m14qdiyhcn.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> "David S. Miller" <davem@davemloft.net> writes:
> 
>>This usually means that there is some DMA corruption.
>>For example, some bug in the x86_64 IOMMU code or similar
>>causes a bogus DMA address to be fed to the tg3 or even
>>worse a DMA mapping is unmapped before tg3 is actually
>>done with it.
> 
> 
> IOMMU code on x86-64 should be never active unless Stephen
> used IOMMU_DEBUG or iommu=force.  THat is because the tg3
> is a 64bit capable device and should always use bypass.

how is this detected? we have a board that is using a 32bit e1000 and we 
have to use iommu=force otherwise it doesn't do the right thing with > 
4GB of RAM.

peter
