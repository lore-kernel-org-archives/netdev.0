From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 1/22] xfrm: Add direction information to xfrm_state
Date: Fri, 21 Jan 2005 14:38:57 -0800
Message-ID: <20050121143857.69282605.davem@davemloft.net>
References: <20041230035000.01@ori.thedillows.org>
	<20041230035000.10@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <20041230035000.10@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Dec 2004 03:48:34 -0500
David Dillow <dave@thedillows.org> wrote:

> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2004/12/30 00:27:15-05:00 dave@thedillows.org 
> #   Add direction information to xfrm_state. This will be needed to
> #   offload xfrm processing to the NIC.

And xfrm_state, when actually used, does not exist in a vacuum.
It is being used in terms of a particular xfrm_policy which has
a direction indicator already.

Given that, it seems the xfrm_state is not only unnecessary, but
also slightly illogical in fact.  If you need the direction, you
should make sure that at those places you can get back to the
policy in order to obtain that piece of information.
