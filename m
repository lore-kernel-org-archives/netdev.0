From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 1/22] xfrm: Add direction information to xfrm_state
Date: Tue, 25 Jan 2005 22:17:26 -0800
Message-ID: <20050125221726.73d4b7ab.davem@davemloft.net>
References: <20041230035000.01@ori.thedillows.org>
	<20041230035000.10@ori.thedillows.org>
	<20050121143857.69282605.davem@davemloft.net>
	<1106373022.3691.36.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <1106373022.3691.36.camel@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 22 Jan 2005 00:50:22 -0500
David Dillow <dave@thedillows.org> wrote:

> Hmm, I can see having netdev->xfrm_bundle_add() assume a outbound state,
> since it's only called for Tx.
> 
> Rx offloading could be interesting, but it looks like I could hook into
> net/xfrm/xfrm_policy.c:__xfrm_policy_check(), and add the xfrm_states
> seen there to a work queue for offloading. netdev->xfrm_state_add()
> would then only see inbound states.
> 
> Sound sane?

You really can't get at the policies at these places somehow?
Even by passing down the xfrm_policy pointer into these
call chains?

If you could get at the xfrm_policy, then you could get the
direction.
