From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] allow setting mtu and txqlen via RTM_SETLINK and provide txqlen via RTM_GETLINK
Date: Tue, 24 Aug 2004 20:15:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824181507.GK21296@postel.suug.ch>
References: <20040824094952.GF21073@postel.suug.ch> <E1BzYMJ-000208-00@gondolin.me.apana.org.au> <20040824120442.GA21296@postel.suug.ch> <20040824103205.1ea9c999.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040824103205.1ea9c999.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20040824103205.1ea9c999.davem@redhat.com> 2004-08-24 10:32
> On Tue, 24 Aug 2004 14:04:42 +0200
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > * Herbert Xu <E1BzYMJ-000208-00@gondolin.me.apana.org.au> 2004-08-24 20:16
> > > Please think about the meaning of the value.  Is anyone going to have a queue
> > > bigger than 2^32?
> > > 
> > > And if the answer is yes, then please use u64.
> > 
> > Can you please explain the actual reason for using a fixed width
> > type when all existing numeric attributes use arch depedent types?
> 
> Because otherwise things will break and explode for 32-bit
> binaries running on 64-bit kernels, which is the situation
> for the majority of userland on some platforms.

> Also, we eventually want to be able to transmit netlink
> messages over real networks to remote clients.

Which would be no problem as the size of the attribute is
available to userspace.

> Therefore, like any other real network protocol, we should
> use fixed sized types in the data.

I'm fine with that, as long as it's done the same way for all
attributes.
