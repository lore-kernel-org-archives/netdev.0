From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Check connect address in NETLINK
Date: Wed, 30 Jun 2004 16:00:45 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630120045.GA7973@ms2.inr.ac.ru>
References: <20040628231439.GA3021@gondor.apana.org.au> <20040629082252.GA26866@ms2.inr.ac.ru> <20040629084552.GA6202@gondor.apana.org.au> <20040629111433.GA28463@ms2.inr.ac.ru> <20040629111833.GA22880@gondor.apana.org.au> <20040630112751.GA31160@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040630112751.GA31160@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> +	if (sock->sk_socket->state == SS_CONNECTED &&
> +	    nlk->dst_pid != nlk_sk(ssk)->pid) {

No-no-no! sock->sk_socket can be NULL at this point.

You can use sock->sk_state =  TCP_ESTABLISHED, forxample.

Alexey
