From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] pci_get_slot()
Date: Wed, 17 Dec 2003 16:24:44 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031218002444.GI6258@kroah.com>
References: <20031015183213.GG16535@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
        linux-pci@atrey.karlin.mff.cuni.cz, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
Content-Disposition: inline
In-Reply-To: <20031015183213.GG16535@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 15, 2003 at 07:32:13PM +0100, Matthew Wilcox wrote:
> 
> Hi Linus.
> 
> tg3.c has a bug where it can find the wrong 5704 peer on a machine with
> PCI domains.  The problem is that pci_find_slot() can't distinguish
> whether it has the correct domain or not.
> 
> This patch fixes that problem by introducing pci_get_slot() and converts
> tg3 to use it.  It also fixes another problem where tg3 wouldn't find
> a peer on function 7 (0 to <8, not 0 to <7).

I've applied the pci portions of this patch to my trees and will send it
on after 2.6.0 is out.

thanks,

greg k-h
