From: jamal <hadi@cyberus.ca>
Subject: Re: Allowing netlink_family to be any integer (was: [PATCH 2.6]
	iptables CLUSTERIP target)
Date: 22 Oct 2004 08:53:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098449582.1106.92.camel@jzny.localdomain>
References: <20041021142527.GG3551@sunbeam.de.gnumonks.org>
	 <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au>
	 <20041021225315.GH19714@rei.reeler.org>
	 <20041022122533.GA9713@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Harald Welte <laforge@netfilter.org>,
        lmb@suse.de, ahu@ds9a.nl, hch@infradead.org, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041022122533.GA9713@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-22 at 08:25, Herbert Xu wrote:
> On Fri, Oct 22, 2004 at 12:53:15AM +0200, Thomas Graf wrote:
> > 
> > The only real problem I see is sk_protocol being only 8bit as
> > limiting factor.
> 
> Well we wouldn't be using sk_protocol to look things up anymore.
> We'd be holding a reference on the family directly once the socket
> is created.

Thats why i said:
This does not exclude the use of the netlink numbers, but should ease
them. I think that rtnetlink is already overloaded and would benefit
from having a clean split. As an example things like links and IPaddress
should probably reside elsewhere since they are generic enough a
service.

Orthogal to this:
If we could get more people to use the work from Evgeniy as opposed to
creating a new netlink protocols, then it would benefit people - Harald
could have used that scheme in what he was trying to do for example.

cheers,
jamal
