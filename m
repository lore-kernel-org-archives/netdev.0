From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Fri, 27 May 2005 16:13:20 +0200
Message-ID: <20050527141320.GQ15391@postel.suug.ch>
References: <1117197157.6688.24.camel@localhost.localdomain> <20050527125010.GO15391@postel.suug.ch> <1117202331.6383.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117202331.6383.39.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117202331.6383.39.camel@localhost.localdomain> 2005-05-27 09:58
> On Fri, 2005-27-05 at 14:50 +0200, Thomas Graf wrote:
> 
> 
> >  
> > -#define NLMSG_PUT(skb, pid, seq, type, len) \
> > +#define NLMSG_NEW(skb, pid, seq, type, len, flags) \
> 
> How about introducing NLMSG_NEW and leave NLMSG_PUT where it is?
> This way we could do incremental updates. If there are not too many of
> those NLMSG_PUT around, then it shouldnt be an issue.

That is what the patch does but the diff looks a bit irritating.
1) Introduce NLMSG_NEW to take flags
2) Make NLMSG_PUT call NLMSG_NEW with flags==0
3) Change __nlmsg_put to take flags argument

> The first change would be definetely on top of the current patch i sent
> which is well deserved.
> Lets have Dave swallow my patch then either you or i could make those
> changes. Sounds reasonable?

Sure.
