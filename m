From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] IPv6: Allow the MTU of ipip6 tunnel to be set below 1280
Date: Fri, 27 Sep 2013 12:58:56 +0200
Message-ID: <20130927105856.GF28287@order.stressinduktion.org>
References: <1380207108-20030-1-git-send-email-oghorbell@gmail.com> <20130927083730.GC28287@order.stressinduktion.org> <CA+ev270=P9txSvo7AZN0YcsopwhCYtJCgcZCPsdofEJ+BX+EUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oussama Ghorbel <oghorbell@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+ev270=P9txSvo7AZN0YcsopwhCYtJCgcZCPsdofEJ+BX+EUQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 27, 2013 at 11:45:48AM +0100, Oussama Ghorbel wrote:
> The ip6_tunnel.c module would be then dependent on ip_tunnel.c and may
> be it would not be good thing?

It could just be a static inline in some shared header. So there would
be no compile-time dependency.

> As I have check in v3.10 there is no call from ip6_tunnel to ip_tunnel...
> 
> For information, there is no check for the maximum MTU for ipv4 in the
> patch as this is not done for ipv6.

I understand, but it would be better to limit the MTU here. There is a
(non-jumo) IPV6_MAXPLEN constant.

Looking through the source it seems grev6 does actually check this,
so it would not hurt adding them here, too.

Otherwise, I think your patch is fine.

Greetings,

  Hannes
