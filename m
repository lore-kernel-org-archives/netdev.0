From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (1/3) tcp - choose congestion algorithm at
	initialization
Date: Tue, 28 Sep 2004 09:08:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096387734.21799.1.camel@localhost.localdomain>
References: <20040927111834.48c7baab@zqx3.pdx.osdl.net>
	 <E1CC3ei-00020G-00@gondolin.me.apana.org.au>
	 <20040927225858.3a1665f1.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040927225858.3a1665f1.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-09-27 at 22:58 -0700, David S. Miller wrote:
> On Tue, 28 Sep 2004 08:07:36 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Stephen Hemminger <shemminger@osdl.org> wrote:
> > > The choice of congestion algorithm needs to be made when connection
> > > is setup to avoid problems when the sysctl values change later and the
> > > necessary data hasn't been collected.
> > 
> > Could this be chosen by a setsockopt as well?
> 
> If we export such things with a user visible
> interface, that makes it harder to rip out the
> congestion control algorithm later.  Such an
> action is very likely so...

The current set of algorithm's is because we haven't found the right
one. If it turns out there are multiple algortihm's that make sense to
support long term, then the choice should be done in as route hints
not as part of the user API.
