From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.11 4/8] tg3: Add msi test
Date: Tue, 22 Mar 2005 15:40:30 -0800
Message-ID: <20050322154030.310e85c1.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3E2E@NT-IRVA-0741.brcm.ad.broadcom.com>
	<424098E2.6090007@pobox.com>
	<20050322141714.4515258f.davem@davemloft.net>
	<42409BA4.3090302@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <42409BA4.3090302@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Mar 2005 17:26:44 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> I disagree: this will hide bugs.

It actually spots them too. :-)  If you'd like it to print out
something like:

	TG3 MSI test failed on chipset ven[%x] devid[%x] please
	email this info to PCI maintainers at x@y.com

that's fine.

> We already have a standard process in Linux to handle this stuff:
> 
> * avoid platform tests in the driver
> * when the driver fails, have the user try "pci=nomsi"
> * if that works, add system to blacklist

Just because it's what we've been doing doesn't mean it's the
best solution in this case.

If you hope users will just report this stuff, most of them won't.
They'll say Linux doesn't work on my computer and I have real life
stuff to take care of so I'll install freebsd or windows or a different
networking card and get on with life.

Eventually, say over a year or so, the database of bad chipsets will
get built with your scheme, but to much hardship and pain to users.
