From: Guy Harris <guy@alum.mit.edu>
Subject: Re: [GIT PULL] parisc architecture updates for v4.3
Date: Tue, 3 Nov 2015 15:43:06 -0800
Message-ID: <D6403D2F-339E-4986-ABED-26455A157F7A@alum.mit.edu>
References: <20151025114934.GA11108@ls3530.box> <CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com> <56393D46.6060903@gmx.de>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	John David Anglin <dave.anglin@bell.net>,
	Network Development <netdev@vger.kernel.org>
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:38717 "EHLO c.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965135AbbKCXnS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 18:43:18 -0500
In-Reply-To: <56393D46.6060903@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Nov 3, 2015, at 3:03 PM, Helge Deller <deller@gmx.de> wrote:

> Sadly it's nowhere clearly documented how big the L1 cacheline of parisc really is.

To which particular PA-RISC processor are you referring?  It might not be the same on all processors.

If openpa.net is to be believed, then:

The 7100LC has 32 byte cache lines on the off-chip cache:

	http://www.openpa.net/pa-risc_processor_pa-7100lc.html

and the 8500 has "32 or 64 Byte cache line size", which may be referring to the on-chip caches:

	http://www.openpa.net/pa-risc_processor_pa-8500.html