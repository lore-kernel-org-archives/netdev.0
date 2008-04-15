From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 1/2][NETNS]: The net-subsys IDs generator.
Date: Tue, 15 Apr 2008 00:35:35 -0700 (PDT)
Message-ID: <20080415.003535.219653076.davem@davemloft.net>
References: <480083C2.3050007@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	paulmck@linux.vnet.ibm.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41237
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752883AbYDOHfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 03:35:33 -0400
In-Reply-To: <480083C2.3050007@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Sat, 12 Apr 2008 13:41:22 +0400

> To make some per-net generic pointers, we need some way to address
> them, i.e. - IDs. This is simple IDA-based IDs generator for pernet
> subsystems.
> 
> Addressing questions about potential checkpoint/restart problems: 
> these IDs are "lite-offsets" within the net structure and are by no 
> means supposed to be exported to the userspace.
> 
> Since it will be used in the nearest future by devices only (tun,
> vlan, tunnels, bridge, etc), I make it resemble the functionality
> of register_pernet_device().
> 
> The new ids is stored in the *id pointer _before_ calling the init
> callback to make this id available in this callback.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
