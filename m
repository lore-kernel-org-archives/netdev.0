From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (0/9) free_netdev -- delay freeing of net_device
 structure till after last use
Date: Tue, 19 Aug 2003 13:09:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819130921.7c750408.davem@redhat.com>
References: <20030819121800.009db89b.shemminger@osdl.org>
	<20030819124818.476dc36d.davem@redhat.com>
	<3F4284E6.7070709@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, mochel@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F4284E6.7070709@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 16:13:26 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> David S. Miller wrote:
> > Yes, but drivers that want to work with all 2.4.x trees
> > will need some kind of define to tip off of.  Just providing
> > a HAVE_FREE_NETDEV ought to be sufficient.
> > 
> > Jeff?
> 
> Yeah, that works for me.

Ok, so what I'm going to do is apply all of Stephen's
patches and I'll add the HAVE_FREE_NETDEV define to
linux/netdevice.h
