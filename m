From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Wed, 11 Sep 2002 08:27:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <481681441.1031732839@[10.10.2.3]>
References: <m1d6rko9ab.fsf@frodo.biederman.org>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca,
   tcw@tempest.prismnet.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   Nivedita Singhvi <niv@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1d6rko9ab.fsf@frodo.biederman.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Sounds about average for a P3.  I have pushed the full 800MiB/s out of
> a P3 processor to memory but it was a very optimized loop.  Is
> that 420MB/sec of IO on this test?

Yup, Fibre channel disks. So we know we can push at least that.

> Note quite.  But you suck at least 240MB/s of your memory bandwidth with
> DMA from disk, and then DMA to the nic.  Unless there is a highly
> cached component.  So I doubt you can effectively use more than 1 gige
> card, maybe 2.  And you have 8?

Nope, it's operating totally out of pagecache, there's no real disk 
IO to speak of.

> Wow the hardware designers really believed in over-subscription.
> If the busses are just running 64bit/33Mhz you are oversubscribed.
> And at 64bit/66Mhz the pci busses can easily swamp the system 
> 533*4 ~= 2128MB/s. 

Two 32bit buses (or maybe it was just one) and two 64bit buses,
all at 66MHz. Yes, the PCI buses can push more than the backplane,
but things are never perfectly balanced in reality, so I'd prefer
it that way around ... it's not a perfect system, but hey, it's
Intel hardware - this is high volume market, not real high end ;-)

> What kind of memory bandwidth does the system have, and on which
> bus are the memory controllers?  I'm just curious  

Memory controllers are hung off the interconnect, slightly difficult
to describe. Look for docs on the Intel profusion chipset, or I can
send you a powerpoint (yeah, yeah) presentation when I get into work
later today if you can't find it. Theoretical mem bandwidth should
be 1600MB/s if you're balanced across the CPUs, in practice I'd
expect to be able to push somewhat over 800Mb/s.

M.
