From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 7/7] netpoll: avoid kfree_skb on packets with destructo
Date: Thu, 3 Mar 2005 13:29:06 -0800
Message-ID: <20050303132906.2b5d597f.davem@davemloft.net>
References: <7.454130102@selenic.com>
	<8.454130102@selenic.com>
	<20050303130031.066f0862.davem@davemloft.net>
	<42277ED6.4020707@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, netdev@oss.sgi.com, jmoyer@redhat.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <42277ED6.4020707@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 03 Mar 2005 16:17:10 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Heh, I was just writing this same message.
> 
> On a related note...  David, I would prefer if you merged up the netpoll 
> stuff, since it touches mainly net/*
> 
> Is that cool w/ you?

No problem.  I still don't like this code in that it adds a locking
penalty to everyone just by virtue of enabling netpoll.  We've worked
so hard with things like NETIF_F_LLTX to eliminate locking, so this
would be a huge step backwards.
