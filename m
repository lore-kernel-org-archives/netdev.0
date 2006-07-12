From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: converting generic HDLC to use netif_dormant*()
Date: Wed, 12 Jul 2006 13:46:32 -0700 (PDT)
Message-ID: <20060712.134632.06531928.davem@davemloft.net>
References: <m3veq3suve.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2950
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751226AbWGLUpl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 16:45:41 -0400
To: khc@pm.waw.pl
In-Reply-To: <m3veq3suve.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Tue, 11 Jul 2006 23:18:45 +0200

> This patch converts generic HDLC (and WAN drivers using it) from
> hdlc_set_carrier() to netif_dormant*() interface.
> WAN hardware drivers should now use netif_carrier_on|off() like
> other network drivers.
> 
> Please apply. Thanks.
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

Applied.
