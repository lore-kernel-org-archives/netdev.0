From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] fix zombie netlink socket in user space
Date: 19 Sep 2004 17:02:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095627770.1049.0.camel@jzny.localdomain>
References: <E1C8weq-0000bD-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C8weq-0000bD-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Theres also a fundamental issue in trying to control bind/connect
behavior with the way this patch tries to "fix" things. Theres at least
one app i know of which depends on this.
Dave, whats acceptable? My thinking is this should probably be
controlled by something like the SE linux path?

cheers,
jamal

On Sun, 2004-09-19 at 04:02, Herbert Xu wrote: 
> Pablo Neira <pablo@eurodev.net> wrote:
> > 
> > If you try to bind/connect to a non existant netlink socket, client 
> > socket gets succesfully inserted as head in the socket list. The problem 
> > is that the head can't be delete, so that socket stays in the list 
> > forever (see sk_del_node_init).
> 
> Huh? Where does it say that the head can't be deleted?
