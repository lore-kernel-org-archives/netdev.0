From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] RTNETLINK: Protocol family wildcard dumping for routing rules
Date: Fri, 08 Apr 2005 08:09:05 +1000
Message-ID: <E1DJfBR-0007Ym-00@gondolin.me.apana.org.au>
References: <20050407213838.GW26731@postel.suug.ch>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20050407213838.GW26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
>
> diff -Nru a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> --- a/net/core/rtnetlink.c      2005-04-07 23:13:33 +02:00
> +++ b/net/core/rtnetlink.c      2005-04-07 23:13:33 +02:00
> @@ -647,7 +647,8 @@
>        [RTM_GETROUTE - RTM_BASE] = { .dumpit = rtnetlink_dump_all    },
>        [RTM_NEWNEIGH - RTM_BASE] = { .doit   = neigh_add             },
>        [RTM_DELNEIGH - RTM_BASE] = { .doit   = neigh_delete          },
> -       [RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info       }
> +       [RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info       },
> +       [RTM_GETRULE  - RTM_BASE] = { .dumpit = rtnetlink_dump_all    }
> };

Just a trivial comment.  How about adding a comma at the end of the last
entry so that the next patch won't have to touch it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
