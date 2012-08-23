From: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] ipw2100: use is_zero_ether_addr() and is_broadcast_ether_addr()
Date: Fri, 24 Aug 2012 01:12:09 +0400
Message-ID: <CA++WF2O2SJ+_gATBXrDaoGZ2DA18gK=qM8Y4E9No84J3RCW5XA@mail.gmail.com>
References: <CAPgLHd_zKkfbms8pMPiTKtGxWXw9=b0+AftqFxWZCPLb3EBaig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAPgLHd_zKkfbms8pMPiTKtGxWXw9=b0+AftqFxWZCPLb3EBaig-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 23 August 2012 10:53, Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
>
> Using is_zero_ether_addr() and is_broadcast_ether_addr() instead of
> directly use memcmp() to determine if the ethernet address is all zeros.
>
> spatch with a semantic match is used to found this problem.
> (http://coccinelle.lip6.fr/)
>
> Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
> ---
>  drivers/net/wireless/ipw2x00/ipw2100.c | 11 ++---------
>  1 file changed, 2 insertions(+), 9 deletions(-)

Looks fine, thanks.

Stanislav.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
