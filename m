From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] (3/3) vlan - use RCU
Date: Mon, 9 Aug 2004 16:48:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809164805.57f02f81.davem@redhat.com>
References: <20040803105017.0774e1db@dell_ss3.pdx.osdl.net>
	<410FD348.9040301@candelatech.com>
	<20040803134346.341e5636@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040803134346.341e5636@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Aug 2004 13:43:46 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This patch makes VLAN use RCU for the group lookup and removes
> the group_lock.  Since all operations that are done under group_lock
> already have the rtnetlink semaphore (RTNL), the group_lock is unnecessary.
> The result is the vlan code becomes basically lock free in the send/receive
> path.


Applied, thanks Stephen.
