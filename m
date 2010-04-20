From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: emphasize rtnl lock required in
 call_netdevice_notifiers
Date: Tue, 20 Apr 2010 01:45:56 -0700 (PDT)
Message-ID: <20100420.014556.24310877.davem@davemloft.net>
References: <20100420083729.GA2810@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48399
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754047Ab0DTIpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 04:45:51 -0400
In-Reply-To: <20100420083729.GA2810@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 20 Apr 2010 10:37:30 +0200

> Since netdev_chain is guarded by rtnl_lock, ASSERT_RTNL should be present here
> to make sure that all callers of call_netdevice_notifiers does the locking
> properly.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

That seems right, applied, thanks Jiri!
