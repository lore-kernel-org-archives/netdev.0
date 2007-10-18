From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] fix EMAC driver for proper napi_synchronize API
Date: Wed, 17 Oct 2007 20:21:51 -0400
Message-ID: <4716A71F.5000102@garzik.org>
References: <1192513792.19073.23.camel@pasglop>	 <20071016115318.0fc36af3@freepuppy.rosehill>	 <1192589522.11899.130.camel@pasglop> <47157EA4.1000500@garzik.org>	 <1192591481.11899.134.camel@pasglop>	 <20071017083107.6a1b1bd3@freepuppy.rosehill> <1192662843.6783.48.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49948 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762632AbXJRAVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 20:21:54 -0400
In-Reply-To: <1192662843.6783.48.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
> The EMAC driver "fix" was merged by mistake before the dust had settled on
> the new napi synchronize interface (and before it got merged). The final
> version of that function is spelled without underscores.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

applied


