From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 09:22:11 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609091907.Y34702@shell.cyberus.ca>
References: <20030609072227.R34462@shell.cyberus.ca> <20030609.045547.91327851.davem@redhat.com>
 <20030609080430.I34540@shell.cyberus.ca> <20030609.053218.54202815.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030609.053218.54202815.davem@redhat.com>
List-Id: netdev.vger.kernel.org



On Mon, 9 Jun 2003, David S. Miller wrote:

>    From: Jamal Hadi <hadi@shell.cyberus.ca>
>    Date: Mon, 9 Jun 2003 08:18:50 -0400 (EDT)
>
>    I found in my tests with a ethernet driver that prefetching the
>    _next_ dma descriptor gave better numbers than prefetching the
>    current one but i didnt spend too much time.
>
> Two issues:
>
> 1) We have some cycles to borrow for head entry, we can make
>    prefetch right before rcu_read_lock()
>
> 2) Ideally, hash chains will not exceed 1 (2 at the max)
>    entries.
>

I dont think youll see much benefit with 1 or 2 entries. I was thinking
more along the lines of people with over 100K entries total;
Let me run with this and get back to you.

cheers,
jamal

