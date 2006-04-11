From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 3/3] deinline a few large functions in vlan code - v3
Date: Tue, 11 Apr 2006 00:58:58 -0700 (PDT)
Message-ID: <20060411.005858.49205474.davem@davemloft.net>
References: <200604111043.13605.vda@ilport.com.ua>
	<200604111044.05847.vda@ilport.com.ua>
	<200604111047.36941.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: vda@ilport.com.ua
In-Reply-To: <200604111047.36941.vda@ilport.com.ua>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Vlasenko <vda@ilport.com.ua>
Date: Tue, 11 Apr 2006 10:47:36 +0300

> On Tuesday 11 April 2006 10:44, Denis Vlasenko wrote:
> On Tuesday 11 April 2006 10:43, Denis Vlasenko wrote:
> > These patches exclude VLAN code from netdevice drivers
> > and from bonding module, and even remove vlan-related
> > members of struct netdevice if VLAN is not configured.
> > 
> > Compile tested on allyesconfig kernel with CONFIG_8021Q=y,m,n.
> 
> This one add #ifdefs around vlan_rx_* members of struct netdevice,
> and moves large inlines out-of-line.

This is not very nice, there is no way I'm applying these patches.

I think the current situation is far better than the large pile of
ifdefs these patches are adding to the tree.

Let's just leave things the way they are ok?
