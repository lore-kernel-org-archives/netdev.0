From: David Miller <davem@davemloft.net>
Subject: Re: [patch v8, kernel version 3.2.1] Source mode for macvlan
 interface
Date: Tue, 07 Feb 2012 12:10:23 -0500 (EST)
Message-ID: <20120207.121023.2131074219122624371.davem@davemloft.net>
References: <2400968.61328600903168.JavaMail.root@5-MeO-DMT.ynet.sk>
	<15266430.31328603700375.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15266430.31328603700375.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@ynet.sk>
Date: Tue, 7 Feb 2012 09:35:00 +0100 (CET)

> From: Stefan Gula <steweg@gmail.com>
> 
> New mode of macvlan interface called "source" allows one to set a list
> of allowed mac address, which is used to match against source mac
> address from received frames on underlying interface. This allows
> creating mac based VLAN associations, instead of standard port or tag
> based. The feature is useful to deploy 802.1x mac based behavior,
> where drivers of underlying interfaces doesn't allows that.
> Configuration is done through the netlink interface using e.g.:
>  ip link add link eth0 name macvlan0 type macvlan mode source
>  ip link add link eth0 name macvlan1 type macvlan mode source
>  ip link set link macvlan0 type macvlan macaddr add 00:11:11:11:11:11
>  ip link set link macvlan0 type macvlan macaddr add 00:22:22:22:22:22
>  ip link set link macvlan0 type macvlan macaddr add 00:33:33:33:33:33
>  ip link set link macvlan1 type macvlan macaddr add 00:33:33:33:33:33
>  ip link set link macvlan1 type macvlan macaddr add 00:44:44:44:44:44
> This allows clients with MAC addresses 00:11:11:11:11:11,
> 00:22:22:22:22:22 to be part of only VLAN associated with macvlan0
> interface. Clients with MAC addresses 00:44:44:44:44:44 with only VLAN
> associated with macvlan1 interface. And client with MAC address
> 00:33:33:33:33:33 to be associated with both VLANs.
> 
> Signed-off-by: Stefan Gula <steweg@gmail.com>
> 
> ---
> 
> V8 changes:
>    - added ability to list allowed mac address list back using devdump
>      ops method - required previous rtnetlink patch to be applied first

So you can't submit this until we've applied the final version of that
patch, because you have no idea what the exact mechanism is going to be to
enable dumping of your state, and therefore you can't code to the API
that enables your part of the dump.

The way that you rush your work is irritating, let things run their
course, in as much time as it takes.

And frankly there is no rush on this, as the next merge window for
new features is several months away.
