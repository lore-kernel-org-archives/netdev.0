From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/3] macvlan: use rx_handler_data pointer
 to store macvlan_port pointer V2
Date: Tue, 15 Jun 2010 11:50:04 -0700 (PDT)
Message-ID: <20100615.115004.232740452.davem@davemloft.net>
References: <20100610133412.GC2618@psychotron.lab.eng.brq.redhat.com>
	<20100610133547.GE2618@psychotron.lab.eng.brq.redhat.com>
	<20100615132756.GA3797@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, kaber@trash.net,
	eric.dumazet@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41567
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932400Ab0FOStx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 14:49:53 -0400
In-Reply-To: <20100615132756.GA3797@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 15 Jun 2010 15:27:57 +0200

> Register macvlan_port pointer as rx_handler data pointer. As macvlan_port is
> removed from struct net_device, another netdev priv_flag is added to indicate
> the device serves as a macvlan port.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied.
