From: Thomas Graf <tgraf@suug.ch>
Subject: Re: request_module while holding rtnl semaphore
Date: Tue, 11 Jan 2005 22:50:57 +0100
Message-ID: <20050111215057.GG26856@postel.suug.ch>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <41E34252.504@trash.net> <20050111094752.GD26856@postel.suug.ch> <41E43F83.1090503@trash.net> <20050111214720.GF26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20050111214720.GF26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20050111214720.GF26856@postel.suug.ch> 2005-01-11 22:47
> * Patrick McHardy <41E43F83.1090503@trash.net> 2005-01-11 22:05
> > Thomas Graf wrote:
> > >tcindex returns EBUSY when a filter is changed which does not fit
> > >into the hashtable, so this must be changed.
> > >
> > It's -EAGAIN, so no problem, nothing returns this currently. I'm going to
> > send a patch later.
> 
> Of course, then there is no problem. Will you fix the request_module in
> cls_api.c as well?

Just saw your patch, never mind.
