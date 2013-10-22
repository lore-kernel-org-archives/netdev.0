From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: wan: sbni: remove assembly crc32 code
Date: Tue, 22 Oct 2013 14:38:39 -0400 (EDT)
Message-ID: <20131022.143839.2085832416728125724.davem@davemloft.net>
References: <1382458346-24811-12-git-send-email-andi@firstfloor.org>
	<20131022.135928.2040131908206663695.davem@davemloft.net>
	<20131022183625.GA4382@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, ak@linux.intel.com,
	netdev@vger.kernel.org
To: sebastian@breakpoint.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131022183625.GA4382@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Tue, 22 Oct 2013 20:36:25 +0200

> 
> There is also a C function doing the same thing. Unless the asm code is
> 110% faster we could stick to the C function.
> 
> Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
> ---
> 
> On Tue, Oct 22, 2013 at 01:59:28PM -0400, David Miller wrote:
>> 
>> Is it really impossible to use the generic crc32 support instead of this
>> unsightly custom inline assembler?
> 
> Since you asked for this here step 1.

If it's that simple, this is definitely what we should do.

On the off chance, is there anyone actually able to test this
change? :-)))
