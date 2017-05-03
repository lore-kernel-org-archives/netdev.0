From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: conntrack: Force inlining of build check to
 prevent build failure
Date: Wed, 3 May 2017 14:38:32 +0200
Message-ID: <20170503123832.GB27809@breakpoint.cc>
References: <1493813923-5441-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Arnd Bergmann <arnd@arndb.de>, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51864 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750966AbdECMiz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 08:38:55 -0400
Content-Disposition: inline
In-Reply-To: <1493813923-5441-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geert Uytterhoeven <geert@linux-m68k.org> wrote:
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

Sorry about that, thanks for the fix Geert.

Acked-by: Florian Westphal <fw@strlen.de>
