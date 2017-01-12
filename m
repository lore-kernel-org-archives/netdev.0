From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] tcp: fix tcp_fastopen unaligned access complaints on
 sparc
Date: Thu, 12 Jan 2017 14:49:42 -0800
Message-ID: <1484261382.13165.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1484259898-30719-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        rob.gardner@oracle.com
To: Shannon Nelson <shannon.nelson@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484259898-30719-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-01-12 at 14:24 -0800, Shannon Nelson wrote:
> Fix up a data alignment issue on sparc by swapping the order
> of the cookie byte array field with the length field in
> struct tcp_fastopen_cookie, and making it a proper union
> to clean up the typecasting.
> 
> This addresses log complaints like these:
>     log_unaligned: 113 callbacks suppressed
>     Kernel unaligned access at TPC[976490] tcp_try_fastopen+0x2d0/0x360
>     Kernel unaligned access at TPC[9764ac] tcp_try_fastopen+0x2ec/0x360
>     Kernel unaligned access at TPC[9764c8] tcp_try_fastopen+0x308/0x360
>     Kernel unaligned access at TPC[9764e4] tcp_try_fastopen+0x324/0x360
>     Kernel unaligned access at TPC[976490] tcp_try_fastopen+0x2d0/0x360
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> ---
> v2: Use Eric's suggestion for a union in the struct

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks for fixing this !
