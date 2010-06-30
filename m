From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] ixgbe: skip non IPv4 packets in ATR filter
Date: Tue, 29 Jun 2010 23:15:19 -0700 (PDT)
Message-ID: <20100629.231519.67898298.davem@davemloft.net>
References: <20100630042739.8925.24962.stgit@localhost.localdomain>
	<20100630042859.8925.23844.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	guillaume.gaudonville@6wind.com, peter.p.waskiewicz.jr@intel.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59138
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752159Ab0F3GPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 02:15:05 -0400
In-Reply-To: <20100630042859.8925.23844.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 29 Jun 2010 21:29:00 -0700

> From: Guillaume Gaudonville <guillaume.gaudonville@6wind.com>
> 
> In driver ixgbe, ixgbe_atr may cause crashes for non-ipv4 packets. Just
> add a test to check skb->protocol.  It may crash on short packets due
> to ip_hdr() access.
> 
> Signed-off-by: Guillaume Gaudonville <guillaume.gaudonville@6wind.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
