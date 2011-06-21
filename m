From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [netfilter-core] [PATCH] Remove redundant linux/version.h includes
 from net/
Date: Tue, 21 Jun 2011 08:58:24 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1106210854370.23091@blackhole.kfki.hu>
References: <alpine.LNX.2.00.1106210009520.27735@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, Dmitry Kozlov <xeb@mail.ru>,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1106210009520.27735@swampdragon.chaosbits.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Jun 2011, Jesper Juhl wrote:

> It was suggested by "make versioncheck" that the follwing includes of
> linux/version.h are redundant:
> 
>   /home/jj/src/linux-2.6/net/caif/caif_dev.c: 14 linux/version.h not needed.
>   /home/jj/src/linux-2.6/net/caif/chnl_net.c: 10 linux/version.h not needed.
>   /home/jj/src/linux-2.6/net/ipv4/gre.c: 19 linux/version.h not needed.
>   /home/jj/src/linux-2.6/net/netfilter/ipset/ip_set_core.c: 20 linux/version.h not needed.
>   /home/jj/src/linux-2.6/net/netfilter/xt_set.c: 16 linux/version.h not needed.
> 
> and it seems that it is right.
> 
> Beyond manually inspecting the source files I also did a few build
> tests with various configs to confirm that including the header in
> those files is indeed not needed.
> 
> Here's a patch to remove the pointless includes.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  net/caif/caif_dev.c               |    1 -
>  net/caif/chnl_net.c               |    1 -
>  net/ipv4/gre.c                    |    1 -
>  net/netfilter/ipset/ip_set_core.c |    1 -
>  net/netfilter/xt_set.c            |    1 -
>  5 files changed, 0 insertions(+), 5 deletions(-)

For ipset/xt_set.c:

Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
