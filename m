From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (0/9) free_netdev -- delay freeing of net_device
 structure till after last use
Date: Tue, 19 Aug 2003 12:48:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819124818.476dc36d.davem@redhat.com>
References: <20030819121800.009db89b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, mochel@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030819121800.009db89b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 12:18:00 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> It should be trivial to maintain source compatiablity with 2.4
> which doesn't need to change since it doesn't have sysfs,
> by adding something like this to netdevice.h in 2.4
> 
> static __inline__ void free_netdev(struct net_device *dev) 
> {
> 	kfree(dev);
> }

Yes, but drivers that want to work with all 2.4.x trees
will need some kind of define to tip off of.  Just providing
a HAVE_FREE_NETDEV ought to be sufficient.

Jeff?
