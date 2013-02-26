From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] usb/net/asix_devices: Add USBNET HG20F9 ethernet dongle
Date: Mon, 25 Feb 2013 21:20:08 -0800
Message-ID: <20130226052008.GA25217@kroah.com>
References: <20130226042343.GA27766@kroah.com>
 <20130225.234529.1601978289377551611.davem@davemloft.net>
 <20130226050311.GB21390@kroah.com>
 <20130226.001022.1341620780921182778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gdt@gdt.id.au, linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130226.001022.1341620780921182778.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 26, 2013 at 12:10:22AM -0500, David Miller wrote:
> From: Greg KH <gregkh@linuxfoundation.org>
> Date: Mon, 25 Feb 2013 21:03:11 -0800
> 
> > On Mon, Feb 25, 2013 at 11:45:29PM -0500, David Miller wrote:
> >> From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> >> Date: Mon, 25 Feb 2013 20:23:43 -0800
> >> 
> >> > On Tue, Feb 26, 2013 at 02:47:12PM +1030, Glen Turner wrote:
> >> >> This USB ethernet adapter was purchased in anodyne packaging
> >> >> marked "USB2.0 to LAN" from the computer store adjacent to
> >> >> linux.conf.au 2013 in Canberra (Australia). A web search
> >> >> shows other recent purchasers in Lancaster (UK) and Seattle
> >> >> (USA). Just like an emergent virus, our age of e-commerce and
> >> >> airmail allows underdocumented hardware to spread around the
> >> >> world instantly using the vector of ridiculously low prices.
> >> >> 
> >> >> Paige Thompson, infected via eBay, discovered that the HG20F9
> >> >> is a copy of the Asix 88772B; many viruses copy the RNA of
> >> >> other viruses. See Paige's work at
> >> >> <https://github.com/paigeadele/HG20F9>.
> >> >> This patch uses her discovery to update the restructured Asix
> >> >> driver in the current kernel.
> >> >> 
> >> >> The spread of viruses is often accompanied by rumours. It is
> >> >> rumoured that the HG20F9 has extensions to to provide gigabit
> >> >> ethernet. This patch does not chase that chimera.
> >> >> 
> >> >> Just as some viruses inhabit seemingly-healthy cells, the
> >> >> HG20F9 uses the Vendor ID 0x066b assigned to Linksys Inc.
> >> >> For the present there is no clash of Product ID 0x20f9.
> >> >> 
> >> >> Signed-off-by: Glen Turner <gdt@gdt.id.au>
> >> > 
> >> > That is the best "add a new device id" changelog entry I have _ever_
> >> > seen.  Wonderful job:
> >> > 
> >> > Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> >> 
> >> Was this patch really submitted properly to netdev?  I can't
> >> find it in patchwork at all.
> > 
> > It was Cc: netdev@vger.kernel.org with Message-ID:
> > <1361852232.23197.4.camel@andromache.adelaide.aarnet.edu.au> so it
> > should have gone through there somehow.
> 
> Nope:
> 
> http://marc.info/?t=136185267100001&r=1&w=2
> 
> It didn't make it to any of the lists, that's why you are the
> only person who saw the original patch.

Odd, I've now bounced it to the mailing lists, hopefully it gets there
that way.  If not, I can resend it from me directly.

I'll wait till the morning to see if the messages make it through the
lists.

thanks,

greg k-h
