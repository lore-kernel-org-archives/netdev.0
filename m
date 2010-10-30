From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
	instead of MSI-X
Date: Sat, 30 Oct 2010 17:21:55 -0600
Message-ID: <20101030232155.GA14129@parisc-linux.org>
References: <20101025111235.GA2024@emulex.com> <20101025.120943.189699949.davem@davemloft.net> <20101025223853.GD15074@solarflare.com> <20101025.162535.226782713.davem@davemloft.net> <1288075928.6578.185.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	somnath.kotur@emulex.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Michael Ellerman <michael@ellerman.id.au>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1288075928.6578.185.camel@concordia>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2010 at 05:52:08PM +1100, Michael Ellerman wrote:
> That horse has really really bolted, it's gawn.
> 
> I count 26 drivers with "disable MSI/X" parameters. Some even have more
> than one.

That's 26 patches someone needs to write, then.  You can put my Acked-by
on all of them.

> I agree it's a mess for users, but it's probably preferable to a
> non-working driver.

What more drivers need is an automatic detection of a non-working
interrupt situation, great big warning messages, and fallback to an
alternate interrupt mechanism.  Doing it for one driver, then generalising
as much of it into the core as possible would be nice.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
