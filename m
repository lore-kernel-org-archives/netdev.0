From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 18:09:03 +0100
Message-ID: <1345655343.2709.56.camel@bwh-desktop.uk.solarflarecom.com>
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
	 <1345653844.2709.51.camel@bwh-desktop.uk.solarflarecom.com>
	 <CA+55aFxMD-Jn3fPgum7a+3EhNiWB-Mjv+1yamR7ELHwroA_+7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	David Laight <David.Laight@aculab.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23846 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756897Ab2HVRJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 13:09:08 -0400
In-Reply-To: <CA+55aFxMD-Jn3fPgum7a+3EhNiWB-Mjv+1yamR7ELHwroA_+7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 09:55 -0700, Linus Torvalds wrote:
> On Wed, Aug 22, 2012 at 9:44 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> >
> > Well, when the issue of 64-bit MMIO was discussed earlier this year, you
> > said nothing about this.  I thought the conclusion was that any
> > definitions provided by <asm/io.h> *must* be atomic and drivers can use
> > <asm-generic/io-64-nonatomic-hi-lo.h> or
> > <asm-generic/io-64-nonatomic-lo-hi.h> as a fallback.
> 
> Think 32-bit PCI with a 64-bit CPU.
[...]

Well, sure, I'm assuming that the driver is responsible for checking
that the device and its bus interface support an MMIO of the requested
width.

But the architecture code must be responsible for reporting whether the
host supports it, right?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
