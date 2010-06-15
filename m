From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 2/3] macvlan: use rx_handler_data pointer
 to store macvlan_port pointer
Date: Tue, 15 Jun 2010 14:48:20 +0200
Message-ID: <4C177694.3030804@trash.net>
References: <20100610133412.GC2618@psychotron.lab.eng.brq.redhat.com> <20100610133547.GE2618@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39551 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865Ab0FOMsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 08:48:24 -0400
In-Reply-To: <20100610133547.GE2618@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Register macvlan_port pointer as rx_handler data pointer. As macvlan_port is
> removed from struct net_device, another netdev priv_flag is added to indicate
> the device serves as a macvlan port.

Looks fine to me.

Acked-by: Patrick McHardy <kaber@trash.net>

