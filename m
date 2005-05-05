From: Peter Buckingham <peter@pantasys.com>
Subject: Re: Mystery packet killing tg3
Date: Thu, 05 May 2005 12:02:15 -0700
Message-ID: <427A6DB7.10404@pantasys.com>
References: <20050502162405.65dfb4a9@localhost.localdomain> <20050502200251.38271b61.davem@davemloft.net> <m14qdiyhcn.fsf@muc.de> <42791825.2080204@pantasys.com> <20050505114327.GA51761@muc.de> <427A5363.2080703@pantasys.com> <20050505180609.GB24386@muc.de> <427A6426.40104@pantasys.com> <20050505183144.GD24386@muc.de> <427A6898.4070804@pantasys.com> <20050505185635.GE24386@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050505185635.GE24386@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> With iommu=force or CONFIG_IOMMU_DEBUG all IO is foced 
> through the IOMMU.

okay, that's definitely bad...

> Hmm - if you want to hack the kernel you could add udelay()s
> to the no IOMMU paths in arch/x86_64/kernel/pci-gart.c 
> and see if that cures the problem too.  If yes then the timing
> theory would be proved.
> Actually the IOMMU code does more than just delaying, it also
> does config space accesses which might flush or synchronize
> things in the PCI bridges. Perhaps adding some dummy access
> for that would be good too.

okay, i'll start to take a look at this, but it'll probably be a little 
while before i can really get to it. i'll let you know what i find out.

> The dmesg looks similar to the previous one from the IOMMU
> code perspective.

it actually looks like it's configure correctly now (at least from 
agp-gart messages), before we were getting errors. i guess the bios guys 
finally got it right ;-)

thanks,

peter
