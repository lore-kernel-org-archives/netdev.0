From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] pci_get_slot()
Date: Wed, 15 Oct 2003 15:55:48 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3F8DA644.50403@pobox.com>
References: <20031015183213.GG16535@parcelfarce.linux.theplanet.co.uk> <20031015184104.GA22373@kroah.com> <20031015185053.GH16535@parcelfarce.linux.theplanet.co.uk> <20031015193455.GA23727@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <willy@debian.org>,
	Linus Torvalds <torvalds@osdl.org>,
	"David S. Miller" <davem@redhat.com>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Greg KH <greg@kroah.com>
In-Reply-To: <20031015193455.GA23727@kroah.com>
List-Id: netdev.vger.kernel.org

Greg KH wrote:
> On Wed, Oct 15, 2003 at 07:50:53PM +0100, Matthew Wilcox wrote:
>>The only real way to do it is to inline pci_get_slot() into tg3.  Since I
>>also have a need for it in sym2, that doesn't seem like a sensible idea.
>>It would also be racy since it wouldn't take the pci_bus_lock.
> 
> 
> Ok, fair enough.  I'll add it to my tree to be sent to Linus after 2.6.0
> is out, if Jeff and David agree it's an ok tg3.c patch.


I'm OK with it...   I guess we'll be shipping tg3 and sym2 known-broken 
on PCI domain boxes?

Admittedly it's an uncommon case for tg3...

	Jeff
