From: Peter Buckingham <peter@pantasys.com>
Subject: Re: Mystery packet killing tg3
Date: Thu, 05 May 2005 11:21:26 -0700
Message-ID: <427A6426.40104@pantasys.com>
References: <20050502162405.65dfb4a9@localhost.localdomain> <20050502200251.38271b61.davem@davemloft.net> <m14qdiyhcn.fsf@muc.de> <42791825.2080204@pantasys.com> <20050505114327.GA51761@muc.de> <427A5363.2080703@pantasys.com> <20050505180609.GB24386@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050505180609.GB24386@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> In what initialization exactly? YOu mean changing the pci_set_dma_mask()
> in the e1000 driver?

exactly.
>>Kernel panic - not syncing: Cannot allocate iommu bitmap
> 
> 
> Hmm, that must be a different problem in the IOMMU code
> not related to the e1000. Probably it got confused somehow.
> Why did you get the idea the ethernet driver has anything to do with
> it?

i don't think it has anything to do with the e1000 actually. we only see 
this when the serial console redirection is enabled. It was the only 
dmesg I had lying around that had the IOMMU not forced. We run our 
systems diskless so it's not easy to get the boot log when the ethernet 
device is not working correctly. I can try to get a system with a hard 
drive and give you the dmesg from that instead (probably more useful ;-)

peter
