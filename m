From: "David S. Miller" <davem@redhat.com>
Subject: Re: netdev_ops retraction
Date: Wed, 30 Jul 2003 16:41:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730164108.06062b72.davem@redhat.com>
References: <20030730184416.GI22222@parcelfarce.linux.theplanet.co.uk>
	<20030730233541.GB7057@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20030730233541.GB7057@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Jul 2003 20:35:42 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Em Wed, Jul 30, 2003 at 07:44:16PM +0100, Matthew Wilcox escreveu:
> > I think there's still scope for a netdev_ops patch, but it's of dubious value
> > and more of a 2.7 project.
> 
> OK with me, I mentioned this in a brainstorm and thought of it as a 2.7 thing
> anyway.

I'm ok with the simplified ethtool-only version too.

Although I'm confused about what kind of problem there is with
netdev_ops being such a "large structure".

This is the kind of thing there'd be _ONE_ copy of in each driver,
ala.

struct netdev_ops tg3_netdev_ops {
 ...
	.foo	=	tg3_foo,
 ...
};

...
	tp->dev->netdev_ops = &tg3_netdev_ops;
...

Right?
