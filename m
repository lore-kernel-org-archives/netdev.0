From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 2/22] xfrm: Add xfrm offload management calls to
 struct netdevice
Date: Fri, 21 Jan 2005 14:40:45 -0800
Message-ID: <20050121144045.74d30ef2.davem@davemloft.net>
References: <20041230035000.10@ori.thedillows.org>
	<20041230035000.11@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <20041230035000.11@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Dec 2004 03:48:34 -0500
David Dillow <dave@thedillows.org> wrote:

> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2004/12/30 00:28:25-05:00 dave@thedillows.org 
> #   Add the xfrm offload management calls to struct netdevice.
> #   
> #   xfrm_state_add() is called for inbound xfrm states
> #   xfrm_bundle_add() is called for outbound xfrm bundles
> #   xfrm_state_del() is called for all offloaded xfrms,
> #   	inbound or outbound.
> #   
> #   If a driver adds NETIF_F_IPSEC to its features, it must
> #   provide all three callbacks.
> #   
> #   Signed-off-by: David Dillow <dave@thedillows.org>

I have no problems with this interface.  In fact, just about
whatever works for the card you have would be fine for an
initial implementation.

We know this interface will likely need to change over time
so we should explicitly mark these callbacks as in a state
of flux so that nobody who tries to play with this gets surprised
when we tweak it.
