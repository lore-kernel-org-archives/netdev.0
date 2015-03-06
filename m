From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] fib: make netdev_switch_fib_ipv4_abort in header
 file static inline
Date: Fri, 6 Mar 2015 12:31:56 -0800
Message-ID: <CAE4R7bAASmi+VxbzJ8CKkDpwdtU73HFaDAhyYxd3wDfhmsmqSQ@mail.gmail.com>
References: <1425660268-23344-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:41711 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619AbbCFUb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 15:31:57 -0500
Received: by qgea108 with SMTP id a108so15514810qge.8
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 12:31:56 -0800 (PST)
In-Reply-To: <1425660268-23344-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 6, 2015 at 8:44 AM, Willem de Bruijn <willemb@google.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> When building without CONFIG_NET_SWITCHDEV,
> netdev_switch_fib_ipv4_abort is defined in the header file. It must
> be static inline to avoid build failure at link time.
>
> Fixes: 8e05fd7166c6 ("fib: hook IPv4 fib for hardware offload")
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  include/net/switchdev.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index dc0a5cc..933fac4 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -129,7 +129,7 @@ static inline int netdev_switch_fib_ipv4_del(u32 dst, int dst_len,
>         return 0;
>  }
>
> -void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
> +static inline void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
>  {
>  }


Acked-by: Scott Feldman <sfeldma@gmail.com>
