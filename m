From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] pci_get_slot()
Date: Wed, 15 Oct 2003 12:13:37 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310151213050.1661-100000@home.osdl.org>
References: <20031015184104.GA22373@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matthew Wilcox <willy@debian.org>, "David S. Miller" <davem@redhat.com>,
        Jeff Garzik <jgarzik@pobox.com>, <linux-pci@atrey.karlin.mff.cuni.cz>,
        <netdev@oss.sgi.com>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg KH <greg@kroah.com>
In-Reply-To: <20031015184104.GA22373@kroah.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 15 Oct 2003, Greg KH wrote:
> 
> The check of:
> 	if (dev->bus->number == bus && dev->devfn == devfn)
> in pci_find_slot() doesn't check for the domain?

No, and it doesn't even have anything to check _against_. We don't pass 
the domain down to it.

		Linus
