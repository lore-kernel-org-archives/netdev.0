From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2.6] (3/3) vlan - use RCU
Date: Tue, 03 Aug 2004 14:03:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410FFDB6.8040309@candelatech.com>
References: <20040803105017.0774e1db@dell_ss3.pdx.osdl.net>	<410FD348.9040301@candelatech.com> <20040803134346.341e5636@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040803134346.341e5636@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch makes VLAN use RCU for the group lookup and removes
> the group_lock.  Since all operations that are done under group_lock
> already have the rtnetlink semaphore (RTNL), the group_lock is unnecessary.
> The result is the vlan code becomes basically lock free in the send/receive
> path.

Looks good to me, but I'm fairly ignorant of RCU at this point.  Will
trust Stephen knows what he is doing :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
