From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH/RFC] Let {ip,arp}tables "see" bridged VLAN tagged {I,AR}P
 packets
Date: Mon, 06 Oct 2003 13:24:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F81CF75.5050802@candelatech.com>
References: <200310062204.07230.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge <bridge@osdl.org>, vlan@wanfear.com,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200310062204.07230.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bart De Schuymer wrote:
> - add some code in vlan_dev.c::vlan_dev_hard_start_xmit():
> skb->protocol = __constant_htons(ETH_P_8021Q);
> skb->mac.raw -= VLAN_HLEN;
> skb->nh.raw -= VLAN_HLEN;

I wonder if this is what was messing up the tcpdump packet capture
as well?

It would be fine with me if you un-conditionally exported the
vlan hard-start-xmit pointer, but I don't feel strongly either way.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
