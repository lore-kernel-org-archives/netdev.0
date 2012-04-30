From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION][PATCH V5 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Mon, 30 Apr 2012 13:41:48 -0400 (EDT)
Message-ID: <20120430.134148.722408249106132399.davem@davemloft.net>
References: <1335753820.20866.27.camel@pasglop>
	<1335759088.20866.32.camel@pasglop>
	<4F9E1CDB.9020104@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org,
	eric.dumazet@gmail.com, matt@ozlabs.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: kaffeemonster@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F9E1CDB.9020104@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Seiffert <kaffeemonster@googlemail.com>
Date: Mon, 30 Apr 2012 07:02:19 +0200

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
> Tested-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Signed-off-by: Jan Seiffert <kaffeemonster@googlemail.com>

Applied, thanks.
