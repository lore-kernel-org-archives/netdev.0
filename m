From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: secure bpf jit against
 spraying attacks
Date: Sun, 19 May 2013 23:56:15 -0700 (PDT)
Message-ID: <20130519.235615.1794473948693729339.davem@davemloft.net>
References: <1368844623.3301.142.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hpa@zytor.com, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368844623.3301.142.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 May 2013 19:37:03 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> hpa bringed into my attention some security related issues
> with BPF JIT on x86.
> 
> This patch makes sure the bpf generated code is marked read only,
> as other kernel text sections.
> 
> It also splits the unused space (we vmalloc() and only use a fraction of
> the page) in two parts, so that the generated bpf code not starts at a
> known offset in the page, but a pseudo random one.
> 
> Refs:
> http://mainisusuallyafunction.blogspot.com/2012/11/attacking-hardened-linux-systems-with.html
> 
> Reported-by: H. Peter Anvin <hpa@zytor.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
