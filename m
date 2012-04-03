From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION][PATCH V4 2/3] bpf jit: Let the x86 jit handle
 negative offsets
Date: Tue, 03 Apr 2012 18:02:36 -0400 (EDT)
Message-ID: <20120403.180236.324578658342931623.davem@davemloft.net>
References: <4F75CA89.4010709@googlemail.com>
	<4F75D015.30609@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com
To: kaffeemonster@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F75D015.30609@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Seiffert <kaffeemonster@googlemail.com>
Date: Fri, 30 Mar 2012 17:24:05 +0200

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
> Signed-of-by: Jan Seiffert <kaffeemonster@googlemail.com>

Applied, but with trailing empty lines removed:

> diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
> index 6687022..2897d7f 100644
> --- a/arch/x86/net/bpf_jit.S
> +++ b/arch/x86/net/bpf_jit.S
> +	ret
> +

There.
