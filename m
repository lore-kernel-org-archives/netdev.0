From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next-2.6] vlan: Precise RX stats accounting
Date: Tue, 17 Nov 2009 00:20:37 -0800 (PST)
Message-ID: <20091117.002037.229474882.davem@davemloft.net>
References: <4B01558F.5000306@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56225
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753179AbZKQIUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 03:20:21 -0500
In-Reply-To: <4B01558F.5000306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Nov 2009 14:37:19 +0100

> In case dynamic percpu allocation fails, we fallback to previous
> mode (sharing dev->stats counter)

Eric, please make allocation failure cause the vlan_setup()
to fail and propagate -EFAULT back to the caller.

Thanks.
