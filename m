From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] allow setting mtu and txqlen via RTM_SETLINK and provide txqlen via RTM_GETLINK
Date: Tue, 24 Aug 2004 12:26:38 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BzR1C-0000c4-00@gondolin.me.apana.org.au>
References: <20040823205114.GB19921@postel.suug.ch>
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20040823205114.GB19921@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
>
> +       RTA_PUT(skb, IFLA_TXQLEN, sizeof(unsigned long), &dev->tx_queue_len);

Please use a fixed width type like u32.  Keep in mind that the ioctl
version is exporting an int.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
