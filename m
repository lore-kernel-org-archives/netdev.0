From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] (3/4) bridge linkstate handling
Date: 29 Jul 2004 08:12:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1091103164.1046.591.camel@jzny.localdomain>
References: <20040728162413.0de73ea3@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040728162413.0de73ea3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-07-28 at 19:24, Stephen Hemminger wrote:
> This makes bridge port status reflect both the state of the interface
> from software (up/down) and the carrier.  It makes STP handle link failure
> (cable breakage, etc).  The original concept comes from a 
> Mark Ruijter <bridge@siennax.com> who implemented it differently.
> My way is simpler and requires no polling.
> 
> Obviously, this link state detection will only work if the network card
> handles the events properly.
> 

nice. Does this entrench STP further in the kernel?
Still planning to move it out to user space?

cheers,
jamal
