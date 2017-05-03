From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: conntrack: Force inlining of build check to
 prevent build failure
Date: Wed, 03 May 2017 09:55:16 -0400 (EDT)
Message-ID: <20170503.095516.84626203716316173.davem@davemloft.net>
References: <1493813923-5441-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        arnd@arndb.de, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493813923-5441-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed,  3 May 2017 14:18:43 +0200

> If gcc (e.g. 4.1.2) decides not to inline total_extension_size(), the
> build will fail with:
> 
>     net/built-in.o: In function `nf_conntrack_init_start':
>     (.text+0x9baf6): undefined reference to `__compiletime_assert_1893'
> 
> or
> 
>     ERROR: "__compiletime_assert_1893" [net/netfilter/nf_conntrack.ko] undefined!
> 
> Fix this by forcing inlining of total_extension_size().
> 
> Fixes: b3a5db109e0670d6 ("netfilter: conntrack: use u8 for extension sizes again")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Pablo, I'm going to apply this directly to my tree to fix this build
failure, I hope you don't mind.

Thanks.
