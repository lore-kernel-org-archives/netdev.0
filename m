From: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] drivers/net/wireless/ipw2x00/ipw2100.c: introduce
 missing initialization
Date: Sun, 19 Aug 2012 14:07:46 +0400
Message-ID: <CA++WF2Np75wKXV-2C-FR2vhzcPvMu+z5MixcPy4ajOdHM0K88Q@mail.gmail.com>
References: <1345325159-7365-1-git-send-email-Julia.Lawall@lip6.fr>
	<CA++WF2MmTe6WP6MQRV-v1VwkpcUrw4hU6yh79NdG-K4snzQkbg@mail.gmail.com>
	<alpine.DEB.2.02.1208191149400.2031@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.02.1208191149400.2031-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 19 August 2012 13:49, Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org> wrote:
> From: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
>
> The result of one call to a function is tested, and then at the second call
> to the same function, the previous result, and not the current result, is
> tested again.
>
> Also changed &bssid to bssid, at the suggestion of Stanislav Yakovlev.
>
> The semantic match that finds the first problem is as follows:
>
> (http://coccinelle.lip6.fr/)
>
> // <smpl>
> @@
> expression ret;
> identifier f;
> statement S1,S2;
> @@
>
> *ret = f(...);
> if (\(ret != 0\|ret < 0\|ret == NULL\)) S1
> ... when any
> *f(...);
> if (\(ret != 0\|ret < 0\|ret == NULL\)) S2
> // </smpl>
>
> Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
>
> ---
> v2: changed &bssid to bssid
>

Thank you, Julia.

Stanislav.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
