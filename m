From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 NET] Adjust RTATTR_MAX to IFLA_* changes
Date: Thu, 9 Sep 2004 19:49:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909174943.GA19155@postel.suug.ch>
References: <20040909163131.GA18951@postel.suug.ch> <20040909103149.248a603e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, eric.lemoine@gmail.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040909103149.248a603e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20040909103149.248a603e.davem@davemloft.net> 2004-09-09 10:31
> On Thu, 9 Sep 2004 18:31:31 +0200
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > IFLA_MAX is now bigger than RTA_MAX with the latest changes in IFLA_*.
> > Adjust RTATTR to point to IFLA_MAX to have big enough buffer in
> > rtnetlink_rcv_msg.
> 
> Ok, this is going to get silly if some other attribute gets
> larger than IFLA_* next.
> 
> We should just compute this thing at run time.
> Else, if the macro can't be deleted because there
> are non-trivial other uses, use some expression
> involving max().
> 
> I just checked iproute2 sources and it does not reference
> this thing, so probably best to kill it off, like so.

This is even better, works fine for me.
