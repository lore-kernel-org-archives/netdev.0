From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 4/22] xfrm: Try to offload inbound xfrm_states
Date: Fri, 21 Jan 2005 14:56:08 -0800
Message-ID: <20050121145608.65ad2d48.davem@davemloft.net>
References: <20041230035000.12@ori.thedillows.org>
	<20041230035000.13@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <20041230035000.13@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Dec 2004 03:48:35 -0500
David Dillow <dave@thedillows.org> wrote:

> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2004/12/30 00:33:11-05:00 dave@thedillows.org 
> #   Plumb in offloading of inbound xfrm_states.
> #   
> #   Signed-off-by: David Dillow <dave@thedillows.org>

Hmmm, this seems to deadlock.  xfrm_state_add() is invoked
with the RTNL semaphore already acquired.  For example, via
xfrm_user.c:xfrm_add_sa()
