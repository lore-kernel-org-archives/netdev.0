From: Ben Greear <greearb@candelatech.com>
Subject: Re: Help with bugfix for bond active-backup mode + vlans
Date: Mon, 24 Jul 2006 10:58:54 -0700
Message-ID: <44C50A5E.80009@candelatech.com>
References: <200607241837.42626.Christophe.Devriese@eurid.eu> <200607241749.k6OHn1hg030011@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christophe Devriese <Christophe.Devriese@eurid.eu>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:32914 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932093AbWGXSBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 14:01:21 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200607241749.k6OHn1hg030011@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:

> 	Another possibility would be to have __vlan_hwaccel_rx check the
> VLAN_DEV_INFO(skb->dev)->real_dev, and if that's a bonding device, apply
> the same logic found in skb_bond().  Or, if there's some way to ask the
> question "is dev a VLAN device?", then that same test could be put into
> skb_bond() and all of the packet suppression fru fru could stay there.

There is a flag in if.h to denote VLAN devices:

/* Private (from user) interface flags (netdevice->priv_flags). */
#define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

