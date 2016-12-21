From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: HalfSipHash Acceptable Usage
Date: Wed, 21 Dec 2016 17:27:02 -0500
Message-ID: <20161221222702.h2vboms776zpgpi4@thunk.org>
References: <1482335804.8944.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161221183751.1123.qmail@ns.sciencehorizons.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, Jason@zx2c4.com, ak@linux.intel.com,
	davem@davemloft.net, David.Laight@aculab.com, djb@cr.yp.to,
	ebiggers3@gmail.com, hannes@stressinduktion.org,
	jeanphilippe.aumasson@gmail.com,
	kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, luto@amacapital.net,
	netdev@vger.kernel.org, tom@herbertland.com,
	torvalds@linux-foundation.org, vegard.nossum@gmail.com
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <kernel-hardening-return-5745-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <20161221183751.1123.qmail@ns.sciencehorizons.net>
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 01:37:51PM -0500, George Spelvin wrote:
> SipHash annihilates the competition on 64-bit superscalar hardware.
> SipHash dominates the field on 64-bit in-order hardware.
> SipHash wins easily on 32-bit hardware *with enough registers*.
> On register-starved 32-bit machines, it really struggles.

And "with enough registers" includes ARM and MIPS, right?  So the only
real problem is 32-bit x86, and you're right, at that point, only
people who might care are people who are using a space-radiation
hardened 386 --- and they're not likely to be doing high throughput
TCP connections.  :-)

					- Ted
