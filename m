From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH][2.4.27-pre4] tcp_input.c compile-time error
Date: Mon, 31 May 2004 08:11:15 -0300
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040531111114.GA19839@logos.cnet>
References: <40BAF132.5010907@ribosome.natur.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mikpe@csd.uu.se, davem@redhat.com, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263370AbUEaLKV@vger.kernel.org>
To: Martin MOKREJ? <mmokrejs@ribosome.natur.cuni.cz>
Content-Disposition: inline
In-Reply-To: <40BAF132.5010907@ribosome.natur.cuni.cz>
List-Id: netdev.vger.kernel.org

On Mon, May 31, 2004 at 10:47:46AM +0200, Martin MOKREJ? wrote:
> This patch has helped to me to compile teh kernel at least. Thanks.
> 
> 
> net/ipv4/tcp_input.c in 2.4.27-pre4 fails to compile:
> 
> tcp_input.c: In function `tcp_rcv_space_adjust':
> tcp_input.c:479: error: structure has no member named `sk_rcvbuf'
> tcp_input.c:480: error: structure has no member named `sk_rcvbuf'
> make[3]: *** [tcp_input.o] Error 1
> 
> The patch below appears to fix this problem, although some netdev
> person should probably check it.

Just pulled davem's tree with a fix. -BK is fixed now.

Thanks!
