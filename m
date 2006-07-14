From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Fri, 14 Jul 2006 14:48:55 -0700 (PDT)
Message-ID: <20060714.144855.62664893.davem@davemloft.net>
References: <20060714113900.029e6a2f@dxpl.pdx.osdl.net>
	<44B7E740.5090004@yahoo.fr>
	<20060714115621.689cd7a0@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: guichaz@yahoo.fr, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11962
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161311AbWGNVsu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 17:48:50 -0400
To: shemminger@osdl.org
In-Reply-To: <20060714115621.689cd7a0@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 14 Jul 2006 11:56:21 -0700

> when data arrives at IP through loopback (and possibly other devices).
> So the field needs to be cleared before it confuses the route code.
> This was seen when running netem over loopback, but there are probably
> other device cases. Maybe this should go into stable?
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Thank goodness this thing is only 3-words in size, this is going to
run on every single IPv4 packet received by the system. :-/

I'll apply this, thanks a lot Stephen.
