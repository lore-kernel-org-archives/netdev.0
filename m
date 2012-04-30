From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Mon, 30 Apr 2012 14:29:59 +1000
Message-ID: <1335760199.20866.33.camel@pasglop>
References: <4F75CA89.4010709@googlemail.com>
	 <4F75D2A5.7060407@googlemail.com>
	 <20120403.180302.342779808900865443.davem@davemloft.net>
	 <1333491102.3040.12.camel@pasglop> <1335753820.20866.27.camel@pasglop>
	 <1335759088.20866.32.camel@pasglop> <4F9E1496.9060603@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	matt@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: kaffeemonster@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F9E1496.9060603@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-30 at 06:27 +0200, Jan Seiffert wrote:
> Benjamin Herrenschmidt schrieb:
> > On Mon, 2012-04-30 at 12:43 +1000, Benjamin Herrenschmidt wrote:
> > 
> >>> Matt's having a look at powerpc
> >>
> >> Ok, he hasn't so I'll dig a bit.
> >>
> >> No obvious wrongness (but I'm not very familiar with bpf), though I do
> >> have a comment: sk_negative_common() and bpf_slow_path_common() should
> >> be made one and single macro which takes the fallback function as an
> >> argument.
> > 
> > Ok, with the compile fix below it seems to work for me:
> > 
> > (Feel free to fold that into the original patch)
> > 
> 
> Should i resend the complete patch with the compile fix?

Won't hurt...

BTW. Any idea about that bpf_program vs. sock_fprog issue I mentioned
earlier ?

Cheers,
Ben.
