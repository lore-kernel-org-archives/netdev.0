From: Andi Kleen <ak@muc.de>
Subject: Re: Mystery packet killing tg3
Date: 5 May 2005 20:31:44 +0200
Message-ID: <20050505183144.GD24386@muc.de>
References: <20050502162405.65dfb4a9@localhost.localdomain> <20050502200251.38271b61.davem@davemloft.net> <m14qdiyhcn.fsf@muc.de> <42791825.2080204@pantasys.com> <20050505114327.GA51761@muc.de> <427A5363.2080703@pantasys.com> <20050505180609.GB24386@muc.de> <427A6426.40104@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 5 May 2005 20:31:44 +0200
To: Peter Buckingham <peter@pantasys.com>
Content-Disposition: inline
In-Reply-To: <427A6426.40104@pantasys.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2005 at 11:21:26AM -0700, Peter Buckingham wrote:
> Andi Kleen wrote:
> >In what initialization exactly? YOu mean changing the pci_set_dma_mask()
> >in the e1000 driver?
> 
> exactly.


That should be impossible. Or it sounds like a serious
hardware problem. DAC should normally always work with all e1000 AFAIK.

Most likely you have some hardware problem and it is somehow magically
worked around by IOMMU remapping. One difference is that
the remapping makes all IO slower, perhaps the changed timing
works around some bug.

Or there is a posting problem somewhere that is worked
around by the additional config accesses in IOMMU.

Have you contacted the e1000 maintainters? 

> >>Kernel panic - not syncing: Cannot allocate iommu bitmap
> >
> >
> >Hmm, that must be a different problem in the IOMMU code
> >not related to the e1000. Probably it got confused somehow.
> >Why did you get the idea the ethernet driver has anything to do with
> >it?
> 
> i don't think it has anything to do with the e1000 actually. we only see 
> this when the serial console redirection is enabled. It was the only 
> dmesg I had lying around that had the IOMMU not forced. We run our 
> systems diskless so it's not easy to get the boot log when the ethernet 
> device is not working correctly. I can try to get a system with a hard 
> drive and give you the dmesg from that instead (probably more useful ;-)

It sounds like something is wrong with your hardware.

-Andi
