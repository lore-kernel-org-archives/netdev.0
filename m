From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] (0/7) ipmr fixes
Date: Thu, 26 Jun 2003 11:14:51 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306261112480.11878-100000@excalibur.intercode.com.au>
References: <20030625114038.176ee030.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030625114038.176ee030.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Jun 2003, Stephen Hemminger wrote:

> These patches fix ip multicast route (ipmr) on 2.5.73.
> 
> 1 - Trivial C99 initialization
> 2 - Change functions/variables to static
> 3 - Drop and reacquire RTNL in error path
> 4 - Use time_after()
> 5 - Use alloc_netdev
> 6 - Fix OOPS on dropped packets
> 7 - Get rid of skb_linearize
> 
> Tested on 8-way SMP by bringing up pimd.

Thanks, all applied to my net-patchmonkey tree at 
bk://kernel.bkbits.net/jmorris/net-2.5


- James
-- 
James Morris
<jmorris@intercode.com.au>
