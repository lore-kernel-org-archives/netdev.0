From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bridge] [Patch] bridge: call NETDEV_ENSLAVE notifiers when
 adding a slave
Date: Thu, 19 May 2011 09:04:11 -0700
Message-ID: <20110519090411.1f039a88@nehalam>
References: <1305794393-20775-1-git-send-email-amwang@redhat.com>
	<1305800661-4081-1-git-send-email-amwang@redhat.com>
	<20110519081213.15c05da2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>, Neil Horman <nhorman@redhat.com>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110519081213.15c05da2@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 May 2011 08:12:13 -0700
Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> On Thu, 19 May 2011 18:24:17 +0800
> Amerigo Wang <amwang@redhat.com> wrote:
> 
> > In the previous patch I added NETDEV_ENSLAVE, now
> > we can notify netconsole when adding a device to a bridge too.
> > 
> > By the way, s/netdev_bonding_change/call_netdevice_notifiers/ in
> > bond_main.c, since this is not bonding specific.
> > 
> > Signed-off-by: WANG Cong <amwang@redhat.com>
> > Cc: Neil Horman <nhorman@redhat.com>
> > 
> 
> Is there a usage for this? What listens for this notification?

Never mind it was in the first patch which you did not send.
You should always put a number on group of patches and send
to all parties.

Also, sending networking patches to LKML is a waste of bandwidth
please don't bother.
