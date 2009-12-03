From: "Patrick Mullaney" <pmullaney@novell.com>
Subject: Re: [PATCH 3/3] macvlan: allow in-kernel modules to create and
	 manage macvlan devices
Date: Thu, 03 Dec 2009 13:45:43 -0700
Message-ID: <4B17C107020000C70007C8CE@soto.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <bridge@lists.linux-foundation.org>,
	<alacrityvm-devel@lists.sourceforge.net>, <kaber@trash.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755650AbZLCUpt@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I hope I didn't confuse things by posting:

netdevice: provide common routine for macvlan and vlan operstate
management

again. I offered to send that out patched against net-next-2.6 last
week and I just got back to following up. I'm fine with you rolling
them into your series too.

Thanks.

On Fri, 2009-11-27 at 23:19 +0100, Arnd Bergmann wrote:
> On Friday 13 November 2009, Patrick Mullaney wrote:
> > @@ -318,7 +318,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
> >  #define MACVLAN_FEATURES \
> >         (NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
> >          NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
> > -        NETIF_F_TSO_ECN | NETIF_F_TSO6)
> > +        NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO)
> >  
> >  #define MACVLAN_STATE_MASK \
> >         ((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
> 
> This hunk looks like it should be a separate patch, because we will
> want to have this independently of the rest. I have taken it into
> a series I'm preparing for a new posting of macvtap based on the
> current net-next tree with my bridge mode changes. I also have
> your patch 1 (the fixed version) and 2 in there. It's currently
> work in progress, but if you are interested, take a look at [1].
> 
> 	Arnd <><
> 
> [1] http://git.kernel.org/?p=linux/kernel/git/arnd/playground.git;a=shortlog;h=refs/heads/macvlan
