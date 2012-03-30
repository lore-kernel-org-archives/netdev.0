From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION][PATCH V4 2/3] bpf jit: Let the x86 jit handle
 negative offsets
Date: Fri, 30 Mar 2012 20:58:00 +0200
Message-ID: <1333133880.2325.2430.camel@edumazet-glaptop>
References: <4F75CA89.4010709@googlemail.com>
	 <4F75D015.30609@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: kaffeemonster@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F75D015.30609@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-03-30 at 17:24 +0200, Jan Seiffert wrote:
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

Nice work Jan, thanks a lot.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
