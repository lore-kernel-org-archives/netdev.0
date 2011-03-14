From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: control carrier based on ports online
Date: Mon, 14 Mar 2011 14:29:08 -0700 (PDT)
Message-ID: <20110314.142908.179940791.davem@davemloft.net>
References: <1649722795.14144.1299480074110.JavaMail.root@tahiti.vyatta.com>
	<4D748CC3.8060603@gmail.com>
	<20110307103406.27330529@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.2p.debian@gmail.com, adamm@zombino.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	andy@greyhouse.net, fubar@us.ibm.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40979
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756584Ab1CNV2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:28:31 -0400
In-Reply-To: <20110307103406.27330529@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 7 Mar 2011 10:34:06 -0800

> This makes the bridge device behave like a physical device.
> In earlier releases the bridge always asserted carrier. This
> changes the behavior so that bridge device carrier is on only
> if one or more ports are in the forwarding state. This
> should help IPv6 autoconfiguration, DHCP, and routing daemons.
> 
> I did brief testing with Network and Virt manager and they
> seem fine, but since this changes behavior of bridge, it should
> wait until net-next (2.6.39).
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6, thanks Stephen.
