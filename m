From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] tulip: de2104x, fix init. sections
Date: Wed, 02 Mar 2005 02:37:25 -0500
Message-ID: <42256D35.10602@pobox.com>
References: <20050301214438.4653810e.randy.dunlap@verizon.net> <422558B2.6020105@pobox.com> <20050302072510.GA12464@infradead.org> <42256B89.2000104@pobox.com> <20050302073255.GA12859@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Randy.Dunlap" <randy.dunlap@verizon.net>, netdev@oss.sgi.com,
        torvalds <torvalds@osdl.org>, akpm <akpm@osdl.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050302073255.GA12859@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Wed, Mar 02, 2005 at 02:30:17AM -0500, Jeff Garzik wrote:
> 
>>When someone proves this is possible, I will accept the code change.  I 
>>doubt this will ever happen, for two reasons:
>>
>>1) Hotplug PCI slots are highly likely to choke on the 2104x's very 
>>early and slightly weird PCI hardware implementation.
>>
>>2) It's an ancient card and nobody will ever bother trying to hotplug it.
> 
> 
> No, it's a matter of correctness.  The pci core can call ->probe all the
> time and every driver must be prepared.  Even if no one tries it physically
> it's easily done with Greg's fake hotplug driver.

The change can be made when it's actually useful to someone.  Making 
janitors and Christoph happy is not a good enough reason in my book.

	Jeff
