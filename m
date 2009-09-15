From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] Have atalk_route_packet() return
 NET_RX_SUCCESS not NET_XMIT_SUCCESS
Date: Mon, 14 Sep 2009 17:06:51 -0700 (PDT)
Message-ID: <20090914.170651.56087750.davem@davemloft.net>
References: <20090913161843.2e2174ba@opy.nosense.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@redhat.com
To: lk-netdev@lk-netdev.nosense.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58870
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757515AbZIOAGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 20:06:35 -0400
In-Reply-To: <20090913161843.2e2174ba@opy.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Date: Sun, 13 Sep 2009 16:18:43 +0930

> Have atalk_route_packet() return NET_RX_SUCCESS not NET_XMIT_SUCCESS
> 
> atalk_route_packet() returns NET_RX_DROP if it's call to
> aarp_send_ddp() returns NET_XMIT_DROP. If aarp_send_ddp() returns
> anything else atalk_route_packet() should return NET_RX_SUCCESS, not
> NET_XMIT_SUCCESS.
> 
> Signed-off-by: Mark Smith <markzzzsmith@yahoo.com.au>

Applied.
