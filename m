From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (0/7) ipmr fixes
Date: Wed, 25 Jun 2003 11:40:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625114038.176ee030.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

These patches fix ip multicast route (ipmr) on 2.5.73.

1 - Trivial C99 initialization
2 - Change functions/variables to static
3 - Drop and reacquire RTNL in error path
4 - Use time_after()
5 - Use alloc_netdev
6 - Fix OOPS on dropped packets
7 - Get rid of skb_linearize

Tested on 8-way SMP by bringing up pimd.
