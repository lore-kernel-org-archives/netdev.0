From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Allow setting dev->weight using ip(8)
Date: Mon, 30 Aug 2004 16:58:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830165851.64cf8822.davem@davemloft.net>
References: <5cac192f040830035669628d1@mail.gmail.com>
	<1093868860.1075.573.camel@jzny.localdomain>
	<1093869740.1076.587.camel@jzny.localdomain>
	<5cac192f0408300735f05aa2d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f0408300735f05aa2d@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 30 Aug 2004 16:35:57 +0200
Eric Lemoine <eric.lemoine@gmail.com> wrote:

> > As Dave pointed out any new attributes go to the end of the enumeration.
> > It may not matter in this case if Dave hasnt applied Thomas' patch.
> > Otherwise IFLA_WEIGHT should be last.
> 
> Right.
> 
> New patch attached.

Please make a patch against Linus's current tree.
I put the rest of your rtnetlink device interface
changes in, and your patches here duplicate all of
that.

I agree also with Jamel wrt. ioctl(), let's not go
there if possible. :-)
