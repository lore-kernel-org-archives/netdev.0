From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH] MAINTAINERS: update the NetLabel and Labeled Networking information
Date: Thu, 10 Aug 2017 15:15:23 -0400
Message-ID: <CAHC9VhSk1veoZJvHjVnSy6ztyDdoHBQOVWMyXb8X4Db+-xXENw@mail.gmail.com>
References: <150239239837.19177.4190318681371376062.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
        selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <150239239837.19177.4190318681371376062.stgit@sifl>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 10, 2017 at 3:13 PM, Paul Moore <pmoore@redhat.com> wrote:
> From: Paul Moore <paul@paul-moore.com>
>
> Signed-off-by: Paul Moore <paul@paul-moore.com>
> ---
>  MAINTAINERS |   24 ++++++++++++++----------
>  1 file changed, 14 insertions(+), 10 deletions(-)

I'm planning on sending this up via the SELinux tree with some other
MAINTAINERS updates, consider this more of a FYI posting.

> diff --git a/MAINTAINERS b/MAINTAINERS
> index 65990909fe73..be25ebaaeec3 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -9112,15 +9112,6 @@ F:       net/*/netfilter/
>  F:     net/netfilter/
>  F:     net/bridge/br_netfilter*.c
>
> -NETLABEL
> -M:     Paul Moore <paul@paul-moore.com>
> -W:     http://netlabel.sf.net
> -L:     netdev@vger.kernel.org
> -S:     Maintained
> -F:     Documentation/netlabel/
> -F:     include/net/netlabel.h
> -F:     net/netlabel/
> -
>  NETROM NETWORK LAYER
>  M:     Ralf Baechle <ralf@linux-mips.org>
>  L:     linux-hams@vger.kernel.org
> @@ -9248,10 +9239,23 @@ F:      net/ipv6/
>  F:     include/net/ip*
>  F:     arch/x86/net/*
>
> -NETWORKING [LABELED] (NetLabel, CIPSO, Labeled IPsec, SECMARK)
> +NETWORKING [LABELED] (NetLabel, Labeled IPsec, SECMARK)
>  M:     Paul Moore <paul@paul-moore.com>
> +W:     https://github.com/netlabel
>  L:     netdev@vger.kernel.org
> +L:     linux-security-module@vger.kernel.org
>  S:     Maintained
> +F:     Documentation/netlabel/
> +F:     include/net/calipso.h
> +F:     include/net/cipso_ipv4.h
> +F:     include/net/netlabel.h
> +F:     include/uapi/linux/netfilter/xt_SECMARK.h
> +F:     include/uapi/linux/netfilter/xt_CONNSECMARK.h
> +F:     net/netlabel/
> +F:     net/ipv4/cipso_ipv4.c
> +F:     net/ipv6/calipso.c
> +F:     net/netfilter/xt_CONNSECMARK.c
> +F:     net/netfilter/xt_SECMARK.c
>
>  NETWORKING [TLS]
>  M:     Ilya Lesokhin <ilyal@mellanox.com>

-- 
paul moore
www.paul-moore.com
