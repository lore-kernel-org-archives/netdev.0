From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] x86: bpf_jit_comp: secure bpf jit against
 spraying attacks
Date: Mon, 20 May 2013 06:34:53 -0700
Message-ID: <1369056893.3301.160.camel@edumazet-glaptop>
References: <1368844623.3301.142.camel@edumazet-glaptop>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B723E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B723E@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-20 at 09:51 +0100, David Laight wrote:

> Hmmm.... anyone looking to overwrite kernel code will then start
> looking for blocks of 0xcc bytes and know that what follows
> is the beginning of a function.
> That isn't any harder than random writes.
> 
> Copying a random part of .rodata might be better - especially
> if you can find part of .rodata.str*.

That's not the point. We want to catch jumps to before/after the code.

An attacker having full access to kernel code in read and write mode has
full power anyway to do whatever he wants.
