From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: use GFP_USER for user-controlled kmalloc
Date: Wed, 02 Dec 2015 23:40:08 -0500 (EST)
Message-ID: <20151202.234008.2105465549392712497.davem@davemloft.net>
References: <CACT4Y+a_V5WQZNEnYkuA3Xc5qCWmLV3oScNeNiATZm-wW5eg3Q@mail.gmail.comc>
	<db23659cdf84bc80aff45e906cbfb67581e7a125.1448901154.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com, nhorman@tuxdriver.com, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	dvyukov@google.com, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com, edumazet@google.com
To: marcelo.leitner@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <db23659cdf84bc80aff45e906cbfb67581e7a125.1448901154.git.marcelo.leitner@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Mon, 30 Nov 2015 14:32:54 -0200

> Dmitry Vyukov reported that the user could trigger a kernel warning by
> using a large len value for getsockopt SCTP_GET_LOCAL_ADDRS, as that
> value directly affects the value used as a kmalloc() parameter.
> 
> This patch thus switches the allocation flags from all user-controllable
> kmalloc size to GFP_USER to put some more restrictions on it and also
> disables the warn, as they are not necessary.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
