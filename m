From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] remove unused netlink NL_EMULATE_DEV code
Date: Tue, 22 Mar 2005 19:22:35 -0800
Message-ID: <20050322192235.03627a5f.davem@davemloft.net>
References: <20050318233637.GS5389@shell0.pdx.osdl.net>
	<423B6DAE.9050803@qualcomm.com>
	<20050319010253.GU5389@shell0.pdx.osdl.net>
	<1111196899.1264.118.camel@jzny.localdomain>
	<423F11C3.2020803@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, chrisw@osdl.org, netdev@oss.sgi.com
To: Max Krasnyansky <maxk@qualcomm.com>
In-Reply-To: <423F11C3.2020803@qualcomm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2005 10:26:11 -0800
Max Krasnyansky <maxk@qualcomm.com> wrote:

> jamal wrote:
> > 1
> > On Fri, 2005-03-18 at 20:02, Chris Wright wrote:
> > 
> > 
> >>I'd prefer that too.  What about the netlink_dev implementation itself?
> >>Should it be marked obsolete?
> >>
> > 
> > It should die - pieces of it have already been slowly disapearing.
> 
> Totally agree. Even for Ethertap it was easy to use Netlink sockets directly.

I've applied Chris's original patch, then killed ethertap and
netlink_dev from my tree.

It's very telling that CONFIG_ETHERTAP was still marked EXPERIMENTAL
:-)
