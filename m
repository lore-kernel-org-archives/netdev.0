From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Tue, 12 Apr 2011 14:16:45 -0700 (PDT)
Message-ID: <20110412.141645.112604563.davem@davemloft.net>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com,
	jesse@nicira.com, ebiederm@xmission.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39075
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932503Ab1DLVRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 17:17:21 -0400
In-Reply-To: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri,  8 Apr 2011 07:48:33 +0200

> Now there are 2 paths for rx vlan frames. When rx-vlan-hw-accel is
> enabled, skb is untagged by NIC, vlan_tci is set and the skb gets into
> vlan code in __netif_receive_skb - vlan_hwaccel_do_receive.
> 
> For non-rx-vlan-hw-accel however, tagged skb goes thru whole
> __netif_receive_skb, it's untagged in ptype_base hander and reinjected
> 
> This incosistency is fixed by this patch. Vlan untagging happens early in
> __netif_receive_skb so the rest of code (ptype_all handlers, rx_handlers)
> see the skb like it was untagged by hw.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> v1->v2:
> 	remove "inline" from vlan_core.c functions

Ok, I've applied this, let's see what happens :-)

Thanks!
