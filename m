From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 4/22] xfrm: Try to offload inbound xfrm_states
Date: Tue, 25 Jan 2005 22:13:25 -0800
Message-ID: <20050125221325.0394417a.davem@davemloft.net>
References: <20041230035000.12@ori.thedillows.org>
	<20041230035000.13@ori.thedillows.org>
	<20050121145608.65ad2d48.davem@davemloft.net>
	<1106373133.3691.40.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <1106373133.3691.40.camel@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 22 Jan 2005 00:52:13 -0500
David Dillow <dave@thedillows.org> wrote:

> > Hmmm, this seems to deadlock.  xfrm_state_add() is invoked
> > with the RTNL semaphore already acquired.  For example, via
> > xfrm_user.c:xfrm_add_sa()
> 
> Are you sure? It worked just fine during testing, and I don't see where
> in the call chain from xfrm_netlink_rcv() to xfrm_state_add() the RTNL
> sema is taken. Perhaps you were thinking of xfrm_cfg_sem?

My bad, you're right.
