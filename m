From: Ben Greear <greearb@candelatech.com>
Subject: Re: PCI interrupt problem: e1000 & Super-Micro X6DVA motherboard
Date: Wed, 23 Mar 2005 19:22:58 -0800
Message-ID: <42423292.60701@candelatech.com>
References: <42421FF2.7050501@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        linux-kernel <linux-kernel@vger.kernel.org>
In-Reply-To: <42421FF2.7050501@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> I'm having a strange problem.  I have an X6DVA motherboard
> with dual 2.8Ghz emt-64 processors, 1GB of RAM, SATA HD, etc.

> I tried kernel 2.6.11 which uses irq 26, and 2.6.10-1.770_FC2smp, which
> maps the irq to 209 or something like that.  Distribution is FC2, x86.
> Kernel is compiled for x86-SMP as well.
> 
> I suspect that this may be a hardware issue of some sort, but if anyone
> has any suggestions as to how to debug this further, please do let
> me know.  I'm attaching the lspci and dmesg output in case that helps.

I am now less certain:  I tried with a separate but similar machine, and
eth3 still has bad interrupt test.  I tried 2.6.9 kernel, same problem.
I tried 2.4.29 kernel (on FC2 distribution), and the same problem exists.

I tried with pci=noacpi, and this just messes up everything (irqs are
disabled, etc).

Could this be a bug in the motherboard implementation?

Off to try some different combinations of NIC hardware...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
