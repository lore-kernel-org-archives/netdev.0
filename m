From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6] fix zombie netlink socket in user space
Date: Sun, 19 Sep 2004 18:02:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C8weq-0000bD-00@gondolin.me.apana.org.au>
References: <414D18EF.3080207@eurodev.net>
Cc: davem@redhat.com, herbert@gondor.apana.org.au, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pablo@eurodev.net (Pablo Neira)
In-Reply-To: <414D18EF.3080207@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pablo Neira <pablo@eurodev.net> wrote:
> 
> If you try to bind/connect to a non existant netlink socket, client 
> socket gets succesfully inserted as head in the socket list. The problem 
> is that the head can't be delete, so that socket stays in the list 
> forever (see sk_del_node_init).

Huh? Where does it say that the head can't be deleted?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
