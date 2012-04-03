From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Tue, 03 Apr 2012 18:03:02 -0400 (EDT)
Message-ID: <20120403.180302.342779808900865443.davem@davemloft.net>
References: <4F75CA89.4010709@googlemail.com>
	<4F75D2A5.7060407@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, matt@ozlabs.org,
	eric.dumazet@gmail.com
To: kaffeemonster@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F75D2A5.7060407@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Seiffert <kaffeemonster@googlemail.com>
Date: Fri, 30 Mar 2012 17:35:01 +0200

> Now the helper function from filter.c for negative offsets is exported,
> it can be used it in the jit to handle negative offsets.
> 
> First modify the asm load helper functions to handle:
> - know positive offsets
> - know negative offsets
> - any offset
> 
> then the compiler can be modified to explicitly use these helper
> when appropriate.
> 
> This fixes the case of a negative X register and allows to lift
> the restriction that bpf programs with negative offsets can't
> be jited.
> 
> Signed-off-by: Jan Seiffert <kaffeemonster@googlemail.com>
> 
> I have only compile tested this, -ENOHARDWARE.
> Can someone with more powerpc kung-fu review and maybe test this?
> Esp. powerpc asm is not my strong point. I think i botched the
> stack frame in the call setup. Help?

I'm not applying this until a powerpc person tests it.

Also, we have an ARM JIT in the tree which probably needs to
be fixed similarly.
