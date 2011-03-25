From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] route: Take the right src and dst addresses in
 ip_route_newports
Date: Fri, 25 Mar 2011 01:29:07 -0700 (PDT)
Message-ID: <20110325.012907.212418471.davem@davemloft.net>
References: <20110325064116.GE1290@secunet.com>
	<20110325064203.GF1290@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53058
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933430Ab1CYI22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 04:28:28 -0400
In-Reply-To: <20110325064203.GF1290@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 25 Mar 2011 07:42:03 +0100

> When we set up the flow informations in ip_route_newports(),  we take the
> address informations from the the rt_key_src and rt_key_dst fields of the
> rtable. They appear to be empty. So take the address informations from
> rt_src and rt_dst instead. This issue was introduced by
> commit 5e2b61f78411be25f0b84f97d5b5d312f184dfd1
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thank you.
