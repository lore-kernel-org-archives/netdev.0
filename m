From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix oops when mangling and brouting and tcpdumping
 packets (revised)
Date: Wed, 25 Aug 2004 16:51:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825165139.3fe6caec.davem@redhat.com>
References: <20040825141539.08ca19b8@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, netdev@oss.sgi.com, bridge@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040825141539.08ca19b8@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Aug 2004 14:15:39 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The ebtables brouting chain, traversed through the call
> br_should_route_hook(), can alter a packet. The redirect target
> does this, f.e., to change the MAC destination.
> 
> Bart discovered this and proposed a patch; this is a revised version.
> This version cleans up the handle_bridge code in net/core/dev.c as well
> as getting rid of extra rcu_read_lock and only does the br_port checking
> once.

Looks good, applied.
