From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [Bridge] Re: [PATCH/RFC] Let {ip, arp}tables "see" bridged VLAN tagged {I, AR}P packets
Date: Mon, 6 Oct 2003 22:58:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310062258.27943.bdschuym@pandora.be>
References: <200310062204.07230.bdschuym@pandora.be> <3F81CF75.5050802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, vlan@wanfear.com, bridge <bridge@osdl.org>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F81CF75.5050802@candelatech.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 06 October 2003 22:24, Ben Greear wrote:
> Bart De Schuymer wrote:
> > - add some code in vlan_dev.c::vlan_dev_hard_start_xmit():
> > skb->protocol = __constant_htons(ETH_P_8021Q);
> > skb->mac.raw -= VLAN_HLEN;
> > skb->nh.raw -= VLAN_HLEN;
>
> I wonder if this is what was messing up the tcpdump packet capture
> as well?

A wrong Ethernet header pointer should probably do the trick.

> It would be fine with me if you un-conditionally exported the
> vlan hard-start-xmit pointer, but I don't feel strongly either way.

Me neither. I just let Dave decide in those cases :-)

cheers,
Bart
