From: DaeSeok Youn <daeseok.youn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] nfc: remove unneeded nfc_put_device() calls
Date: Mon, 14 Apr 2014 11:19:56 +0900
Message-ID: <CAHb8M2Bt2+MD_ZKmA89j4bSmmJ--ut-uvXCWj1_1Q2xaKvLEkQ@mail.gmail.com>
References: <31741678.fEkJSmnf5n@daeseok-laptop.cloud.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <31741678.fEkJSmnf5n-yEt5tssq++YB2AIH5/lADM23vB8/Nvlt@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Can you review this patch?

Thanks.
Daeseok Youn

2014-04-02 16:56 GMT+09:00 Daeseok Youn <daeseok.youn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
>
> If local is NULL, nfs_put_device() is called twice.
> So nfs_put_device() in "if (!local)" is removed.
>
> Signed-off-by: Daeseok Youn <daeseok.youn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  net/nfc/netlink.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
> index b2ad570..3e0a676 100644
> --- a/net/nfc/netlink.c
> +++ b/net/nfc/netlink.c
> @@ -1038,7 +1038,6 @@ static int nfc_genl_llc_sdreq(struct sk_buff *skb, struct genl_info *info)
>
>         local = nfc_llcp_find_local(dev);
>         if (!local) {
> -               nfc_put_device(dev);
>                 rc = -ENODEV;
>                 goto exit;
>         }
> --
> 1.7.4.4
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
