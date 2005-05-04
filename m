From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: Action repeat
Date: Wed, 4 May 2005 16:53:41 +0200
Message-ID: <20050504145341.GG18452@postel.suug.ch>
References: <20050502150632.GM577@postel.suug.ch> <1115207194.7665.109.camel@localhost.localdomain> <20050504123157.GA18452@postel.suug.ch> <1115211549.7665.140.camel@localhost.localdomain> <20050504132822.GB18452@postel.suug.ch> <1115213600.7665.166.camel@localhost.localdomain> <20050504134815.GD18452@postel.suug.ch> <1115214782.7665.184.camel@localhost.localdomain> <20050504140540.GE18452@postel.suug.ch> <1115216629.7906.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115216629.7906.4.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1115216629.7906.4.camel@localhost.localdomain> 2005-05-04 10:23
> On Wed, 2005-04-05 at 16:05 +0200, Thomas Graf wrote:
> 
> 
> >  Assuming we define global as everything and local
> > as per device/(ingress|egress) then we definitely need to invoke
> > a reset on the way over to egress. 
> 
> Agreed. So shall we stick then to just make it a global-only?

As long as we can't find a way to have a well defined local
scope which is both easy to implement and easy to understand
for the user a global-only scope with the ability for the user
to reset the value via the meta action is most reasonable to me.
We need to define this well because it will get to be the backend
for any advanced classyfing over multiple devices. I will give it
some more thinking in the background, in the meantime I suggest
to implement it global-only for now. The global classid issue is
the next item on my list and I should be able to come up with
something this week after posting rtnetlink neighbour tables
patches and the new generic textsearch API + skb search bits +
textsearch ematch which will provide optimized textsearching
facitilies including a simple regular expression for both linear
and non-linear skbs.
