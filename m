From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [IPV4] Remove unsupported DNAT (RTCF_NAT
 and RTCF_NAT) in IPV4
Date: Wed, 09 Jan 2008 00:19:48 -0800 (PST)
Message-ID: <20080109.001948.86613926.davem@davemloft.net>
References: <eb3ff54b0801021331w63637142sd39b6605bd6f8be4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41697
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751006AbYAIITt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 03:19:49 -0500
In-Reply-To: <eb3ff54b0801021331w63637142sd39b6605bd6f8be4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Wed, 2 Jan 2008 23:31:37 +0200

> - The DNAT (Destination NAT) is not implemented in IPV4.
> 
> - This patch remove the code which checks these flags
> in net/ipv4/arp.c and net/ipv4/route.c.
> 
> The RTCF_NAT and RTCF_NAT should stay in the header (linux/in_route.h)
> because they are used in DECnet.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks Rami.

If someone has the stamina, it's very likely that the partial
NAT support in the decnet code can simply be removed.  If
successful, then the in_route.h macros can be removed.
