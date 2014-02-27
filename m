From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] ixgbevf: fix skb->pkt_type checks
Date: Thu, 27 Feb 2014 16:07:41 -0500 (EST)
Message-ID: <20140227.160741.1837528571194344504.davem@redhat.com>
References: <1393454640-19651-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	aaron.f.brown@intel.com, alexander.h.duyck@intel.com,
	jesse.brandeburg@intel.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbaB0VID (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 16:08:03 -0500
In-Reply-To: <1393454640-19651-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 26 Feb 2014 14:44:00 -0800

> skb->pkt_type is not a bitmask, but contains only value at a time from
> the range defined in include/uapi/linux/if_packet.h.
> 
> Checking it like if it was a bitmask of values would also cause
> PACKET_OTHERHOST, PACKET_LOOPBACK and PACKET_FASTROUTE to be matched by this
> check since their lower 2 bits are also set, although that does not fix a real
> bug due to how the checks are used, it is still potentially confusing.
> 
> This bogus check was introduced in commit 815cccbf ("ixgbe: add setlink,
> getlink support to ixgbe and ixgbevf").
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Intel folks, I assume you will pick this up?
