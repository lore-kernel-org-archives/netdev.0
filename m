From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for January 19 (vhost_net)
Date: Wed, 20 Jan 2010 07:48:15 -0800
Message-ID: <20100120074815.ceff3a44.randy.dunlap@oracle.com>
References: <20100119181041.ab55f645.sfr@canb.auug.org.au>
	<20100119104139.2ec9164b.randy.dunlap@oracle.com>
	<20100120113341.GA9610@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:38281 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab0ATPtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 10:49:15 -0500
In-Reply-To: <20100120113341.GA9610@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jan 2010 13:33:41 +0200 Michael S. Tsirkin wrote:

> On Tue, Jan 19, 2010 at 10:41:39AM -0800, Randy Dunlap wrote:
> > On Tue, 19 Jan 2010 18:10:41 +1100 Stephen Rothwell wrote:
> > 
> > > Hi all,
> > > 
> > > Changes since 20100118:
> > 
> > 
> > When CONFIG_TUN is not enabled:
> > 
> > drivers/built-in.o: In function `get_socket':
> > net.c:(.text+0x2899a3): undefined reference to `tun_get_socket'
> > 
> > 
> > so VHOST_NET can either depend on TUN or select TUN, but if it
> > selects TUN, it will also need to select CRC32.
> > 
> > ---
> > ~Randy
> 
> Just to clarify sure, the broken configuration is VHOST=y TUN=m, I sent
> a fixup patch to forbid that configuration.  But both VHOST=y TUN=n and
> VHOST=m TUN=n build fine for me on linux-next (commit
> af2b07e7e0a9c6bf82ce4d6a77f0412ae54f575b).  Randy, could you please
> confirm that VHOST=y TUN=m is what you tested, or alternatively make
> your .config available to me so I can reproduce the problem?

Hi Michael,

You are correct, VHOST_NET=y, TUN=m.

Thanks.
---
~Randy
