From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vlan: Use __vlan_hwaccel_put_tag() in rx
Date: Sun, 15 Nov 2009 22:23:07 -0800 (PST)
Message-ID: <20091115.222307.80411385.davem@davemloft.net>
References: <4AFD8A47.1070908@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35117
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752651AbZKPGWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 01:22:50 -0500
In-Reply-To: <4AFD8A47.1070908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Nov 2009 17:33:11 +0100

> Commit 05423b241311c9380 (vlan: allow null VLAN ID to be used)
> forgot to update __vlan_hwaccel_rx() & vlan_gro_common()
> 
> We need to set VLAN_TAG_PRESENT flag in skb->vlan_tci
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
