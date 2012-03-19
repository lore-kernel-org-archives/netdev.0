From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bpf_jit: fix BPF_S_LDX_B_MSH compilation
Date: Mon, 19 Mar 2012 17:42:41 -0400 (EDT)
Message-ID: <20120319.174241.1785009482969692029.davem@davemloft.net>
References: <1331992184.2466.45.camel@edumazet-laptop>
	<9a0230cb8db556cc9cf5d1f6b2439fb5.squirrel@webmail.greenhost.nl>
	<1332074448.3722.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: indan@nul.nu, wad@chromium.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, matt@ozlabs.org
To: eric.dumazet@gmail.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1332074448.3722.25.camel@edumazet-laptop>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 18 Mar 2012 05:40:48 -0700

> [PATCH] net: bpf_jit: fix BPF_S_LDX_B_MSH compilation
> 
> Matt Evans spotted that x86 bpf_jit was incorrectly handling negative
> constant offsets in BPF_S_LDX_B_MSH instruction.
> 
> We need to abort JIT compilation like we do in common_load so that
> filter uses the interpreter code and can call __load_pointer()
> 
> Reference: http://lists.openwall.net/netdev/2011/07/19/11
> 
> Thanks to Indan Zupancic to bring back this issue.
> 
> Reported-by: Matt Evans <matt@ozlabs.org>
> Reported-by: Indan Zupancic <indan@nul.nu>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and even though libpcap won't generate this I'll queue it up
to -stable anyways.
