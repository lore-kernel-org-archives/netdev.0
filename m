From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc to allocate driver local data structures
Date: Fri, 29 Oct 2004 05:50:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07E0312853C@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <jgarzik@pobox.com>, "netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Christoph Hellwig" <hch@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a trade-off between space allocated via kmalloc and vmalloc. My
understanding is that kmalloc space is more limited than vmalloc. Is
this incorrect?

With the original implementation that used kmalloc for all allocations
in the driver, I have noticed allocation failures when the ring sizes
were set to 4096. Switching the allocation of this space from kmalloc to
vmalloc guarantees successful allocation.

What am I missing?

Ganesh.

-----Original Message-----
From: Christoph Hellwig [mailto:hch@infradead.org] 
Sent: Friday, October 29, 2004 5:15 AM
To: Venkatesan, Ganesh
Cc: jgarzik@pobox.com; netdev
Subject: Re: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc
to allocate driver local data structures

this uses up vmalloc space and thus is a regression.
