From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] (1/3) tcp - choose congestion algorithm at
 initialization
Date: Mon, 27 Sep 2004 22:58:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927225858.3a1665f1.davem@davemloft.net>
References: <20040927111834.48c7baab@zqx3.pdx.osdl.net>
	<E1CC3ei-00020G-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CC3ei-00020G-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 08:07:36 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Stephen Hemminger <shemminger@osdl.org> wrote:
> > The choice of congestion algorithm needs to be made when connection
> > is setup to avoid problems when the sysctl values change later and the
> > necessary data hasn't been collected.
> 
> Could this be chosen by a setsockopt as well?

If we export such things with a user visible
interface, that makes it harder to rip out the
congestion control algorithm later.  Such an
action is very likely so...
