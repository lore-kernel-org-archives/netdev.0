From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2.6.9] Export phys_cpu_present_map
Date: Wed, 20 Oct 2004 19:49:05 +0200
Sender: linux-mips-bounce@linux-mips.org
Message-ID: <20041020174905.GA12697@lst.de>
References: <20041020171626.GG12544@smtp.west.cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, netdev@oss.sgi.com
Return-path: <linux-mips-bounce@linux-mips.org>
To: Tom Rini <trini@kernel.crashing.org>
Content-Disposition: inline
In-Reply-To: <20041020171626.GG12544@smtp.west.cox.net>
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2004 at 10:16:26AM -0700, Tom Rini wrote:
> In net/ipv6/icmp.c::icmpv6_init() there is a call to cpu_possible()
> which preprocesses down to "test_bit(((i)), (phys_cpu_present_map).bits)"
> If ipv6 is a module, phys_cpu_present_map (or cpu_possible_map which is
> defined t phys_cpu_present_map) needs to be exported.

The loop in there should be rewritten as for_each_cpu which doesn't need
this export.
