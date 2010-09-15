From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixgbe: add GRO to vlan_features
Date: Tue, 14 Sep 2010 21:35:44 -0700 (PDT)
Message-ID: <20100914.213544.112598547.davem@davemloft.net>
References: <20100915015052.GA6602@mmm.home.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: bphilips@suse.de
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100915015052.GA6602@mmm.home.ifup.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Brandon Philips <bphilips@suse.de>
Date: Tue, 14 Sep 2010 18:50:53 -0700

> When running a vlan -> bridge -> domU setup I was noticing poor RX
> performance. It seems ixgbe and other drivers don't have NETIF_F_GRO set
> in vlan_features and thus GRO is off by default for vlans.
> 
> I see no reason why the other drivers shouldn't be fixed. If this is OK
> I will go off and fix the rest.
> 
> Signed-off-by: Brandon Philips <bphilips@suse.de>

I think it should be set, but why don't we do this another way?

This feature is a software feature, essentially, so if it is published
in netdev->features we can simply propagate it automatically to
netdev->vlan_features at device registry time in the core networking.

------------------------------------------------------------------------------
Start uncovering the many advantages of virtual appliances
and start using them to simplify application deployment and
accelerate your shift to cloud computing.
http://p.sf.net/sfu/novell-sfdev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
