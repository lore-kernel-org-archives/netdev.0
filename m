From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] tulip: de2104x, fix init. sections
Date: Wed, 2 Mar 2005 07:25:10 +0000
Message-ID: <20050302072510.GA12464@infradead.org>
References: <20050301214438.4653810e.randy.dunlap@verizon.net> <422558B2.6020105@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Randy.Dunlap" <randy.dunlap@verizon.net>, netdev@oss.sgi.com,
        torvalds <torvalds@osdl.org>, akpm <akpm@osdl.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <422558B2.6020105@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 02, 2005 at 01:09:54AM -0500, Jeff Garzik wrote:
> Randy.Dunlap wrote:
> >tulip/de2104x: some __devinit functions were calling __init
> >  functions, made the latter __devinit also;
> 
> Should go the other way:  all the stuff in de2104x should be __init, not 
> __devinit.
> 
> Nobody ever hotplugs a de2104x.

How comes that you want to dictate what cards I put into my hotplug
PCI slots?
