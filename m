From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] tulip: de2104x, fix init. sections
Date: Wed, 2 Mar 2005 07:32:55 +0000
Message-ID: <20050302073255.GA12859@infradead.org>
References: <20050301214438.4653810e.randy.dunlap@verizon.net> <422558B2.6020105@pobox.com> <20050302072510.GA12464@infradead.org> <42256B89.2000104@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
        "Randy.Dunlap" <randy.dunlap@verizon.net>, netdev@oss.sgi.com,
        torvalds <torvalds@osdl.org>, akpm <akpm@osdl.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <42256B89.2000104@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 02, 2005 at 02:30:17AM -0500, Jeff Garzik wrote:
> When someone proves this is possible, I will accept the code change.  I 
> doubt this will ever happen, for two reasons:
> 
> 1) Hotplug PCI slots are highly likely to choke on the 2104x's very 
> early and slightly weird PCI hardware implementation.
> 
> 2) It's an ancient card and nobody will ever bother trying to hotplug it.

No, it's a matter of correctness.  The pci core can call ->probe all the
time and every driver must be prepared.  Even if no one tries it physically
it's easily done with Greg's fake hotplug driver.
