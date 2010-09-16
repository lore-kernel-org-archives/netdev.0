From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: enable GRO by default for vlan
 devices
Date: Wed, 15 Sep 2010 18:16:16 -0700
Message-ID: <20100915181616.578fcd37@nehalam>
References: <20100914.213544.112598547.davem@davemloft.net>
	<20100915163749.GA4191@mmm.home.ifup.org>
	<1284570520.2462.5.camel@edumazet-laptop>
	<20100915.101418.59680213.davem@davemloft.net>
	<1284571476.2293.5.camel@achroite.uk.solarflarecom.com>
	<20100915192424.GE4191@mmm.home.ifup.org>
	<1284588203.2462.81.camel@edumazet-laptop>
	<1284589691.2462.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Brandon Philips <bphilips@suse.de>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, David, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, Ben Hutchings <bhutchings@solarflare.com>,
	Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1284589691.2462.85.camel@edumazet-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2010 00:28:11 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 16 septembre 2010 =E0 00:03 +0200, Eric Dumazet a =E9crit :
> > Le mercredi 15 septembre 2010 =E0 12:24 -0700, Brandon Philips a =E9cri=
t :
> > > Currently vlan devices don't have GRO by default as none of the Ether=
net
> > > drivers add NETIF_F_GRO to their vlan_features.
> > > =

> > > As GRO is a software feature add GRO to dev->vlan_features in
> > > register_netdevice() and let vlan_dev_init() take care that it gets
> > > enabled only when dev->features has NETIF_F_GRO too.
> > > =

> > > Signed-off-by: Brandon Philips <bphilips@suse.de>
> > > =

> > =

> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> > =

> =

> BTW, we have a similar problem for bonding ( GRO is disabled )
> =

> # ethtool -K bond0 gro off
> # ethtool -K bond0 gro on
> Cannot set device GRO settings: Invalid argument
> =

> Same for vlans on top of bond0

Bridge has same problem as well.


-- =


---------------------------------------------------------------------------=
---
Start uncovering the many advantages of virtual appliances
and start using them to simplify application deployment and
accelerate your shift to cloud computing.
http://p.sf.net/sfu/novell-sfdev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
