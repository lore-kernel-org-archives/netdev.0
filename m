From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
	instead of MSI-X
Date: Wed, 27 Oct 2010 23:37:14 -0600
Message-ID: <20101028053714.GD32200@lackof.org>
References: <1288075928.6578.185.camel@concordia> <20101026133233.GH15074@solarflare.com> <1288135235.16778.14.camel@concordia> <20101027.084604.226761472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michael@ellerman.id.au, bhutchings@solarflare.com,
	somnath.kotur@emulex.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101027.084604.226761472.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 27, 2010 at 08:46:04AM -0700, David Miller wrote:
> From: Michael Ellerman <michael@ellerman.id.au>
> Date: Wed, 27 Oct 2010 10:20:35 +1100
> 
> > On Tue, 2010-10-26 at 14:32 +0100, Ben Hutchings wrote:
> >> Michael Ellerman wrote:
> >> > On Mon, 2010-10-25 at 16:25 -0700, David Miller wrote:
> >> > > From: Ben Hutchings <bhutchings@solarflare.com>
> >> > > Date: Mon, 25 Oct 2010 23:38:53 +0100
> > 
> >> > Ethtool would be nice, but only for network drivers. Is there a generic
> >> > solution, quirks are obviously not keeping people happy.
> >>  
> >> Since this is (normally) a property of the system, pci=nomsi is the
> >> generic solution.
> > 
> > Sort of, it's a big hammer. Did all these driver writers not know about
> > pci=nomsi or did they prefer to add a parameter to their driver for some
> > reason?
> 
> Every time I've actually done the work to try and track down the
> true issue, it always turned out to be a PCI chipset problem rather
> than a device specific issue.

I agree with your generalization. I can think of only one exception:
ISTR pre-5705 tg3 chips would send both MSI and assert IRQ line at the same time.

My guess is driver writers just want knob to "work around" any issues
*their* driver might see with chipset. Disabling MSI for all drivers
doesn't leave opportunity for experimenting with individual drivers.

hth,
grant

> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
