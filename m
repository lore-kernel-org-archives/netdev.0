From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (3/4) bridge linkstate handling
Date: Thu, 29 Jul 2004 09:31:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729093120.58258ba9@dell_ss3.pdx.osdl.net>
References: <20040728162413.0de73ea3@dell_ss3.pdx.osdl.net>
	<1091103164.1046.591.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1091103164.1046.591.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 29 Jul 2004 08:12:44 -0400
jamal <hadi@cyberus.ca> wrote:

> On Wed, 2004-07-28 at 19:24, Stephen Hemminger wrote:
> > This makes bridge port status reflect both the state of the interface
> > from software (up/down) and the carrier.  It makes STP handle link failure
> > (cable breakage, etc).  The original concept comes from a 
> > Mark Ruijter <bridge@siennax.com> who implemented it differently.
> > My way is simpler and requires no polling.
> > 
> > Obviously, this link state detection will only work if the network card
> > handles the events properly.
> > 
> 
> nice. Does this entrench STP further in the kernel?
> Still planning to move it out to user space?

The same logic would apply in user space, it would just use the netlink
events that come from netlink messages (RTM_NEWLINK) rather than notifier chain (NETDEV_CHANGE).
