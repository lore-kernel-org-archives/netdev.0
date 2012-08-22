From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 17:44:04 +0100
Message-ID: <1345653844.2709.51.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
	   <503437D4.8090706@zytor.com>
	   <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
	   <20120821.193446.1534561579811962053.davem@davemloft.net>
	   <503450E2.2040504@zytor.com>
	   <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
	   <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>
	   <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
	   <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>
	   <20120822143054.GD9803@kvack.org>
	  <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com>
	  <5034F725.2090802@zytor.com>
	  <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com>
	 <1345650689.2709.32.camel@bwh-desktop.uk.solarflarecom.com>
	 <50350098.6030100@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62952 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753475Ab2HVQoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 12:44:08 -0400
In-Reply-To: <50350098.6030100@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 08:54 -0700, H. Peter Anvin wrote:
> On 08/22/2012 08:51 AM, Ben Hutchings wrote:
> >>
> >> FWIW can you even guarantee to do an atomic 64bit PCIe transfer
> >> on many systems (without resorting to a dma unit).
> >
> > On any architecture that implements readq and writeq these had better be
> > atomic.
> >
> 
> Sorry, you fail.  There are definitely systems in the field where 
> readq() and writeq() are implemented, because the CPU supports them, 
> where the fabric does not guarantee they are intact.

Well, when the issue of 64-bit MMIO was discussed earlier this year, you
said nothing about this.  I thought the conclusion was that any
definitions provided by <asm/io.h> *must* be atomic and drivers can use
<asm-generic/io-64-nonatomic-hi-lo.h> or
<asm-generic/io-64-nonatomic-lo-hi.h> as a fallback.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
