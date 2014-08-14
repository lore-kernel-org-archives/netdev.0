From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v3] sit: Fix ipip6_tunnel_lookup device matching
 criteria
Date: Thu, 14 Aug 2014 14:40:10 -0700 (PDT)
Message-ID: <20140814.144010.2242230149048926758.davem@redhat.com>
References: <1408019240-17751-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	contact@saschahlusiak.de, nicolas.dichtel@6wind.com
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932176AbaHNVkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 17:40:20 -0400
In-Reply-To: <1408019240-17751-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Thu, 14 Aug 2014 15:27:20 +0300

> As of 4fddbf5d78 ("sit: strictly restrict incoming traffic to tunnel link device"),
> when looking up a tunnel, tunnel's underlying interface (t->parms.link)
> is verified to match incoming traffic's ingress device.
> 
> However the comparison was incorrectly based on skb->dev->iflink.
> 
> Instead, dev->ifindex should be used, which correctly represents the
> interface from which the IP stack hands the ipip6 packets.
> 
> This allows setting up sit tunnels bound to vlan interfaces (otherwise
> incoming ipip6 traffic on the vlan interface was dropped due to
> ipip6_tunnel_lookup match failure).
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
