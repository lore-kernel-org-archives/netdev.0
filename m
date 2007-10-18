From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: Add napi_sycnhronize() to sync with napi poll
Date: Thu, 18 Oct 2007 11:19:12 +1000
Message-ID: <1192670352.12879.2.camel@pasglop>
References: <1192513792.19073.23.camel@pasglop>
	 <20071016115318.0fc36af3@freepuppy.rosehill>
	 <1192589522.11899.130.camel@pasglop> <47157EA4.1000500@garzik.org>
	 <1192591481.11899.134.camel@pasglop>
	 <20071017083107.6a1b1bd3@freepuppy.rosehill>
	 <1192658654.6783.43.camel@pasglop>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52175 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759303AbXJRBTa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 21:19:30 -0400
In-Reply-To: <1192658654.6783.43.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> This implements a low level __napi_synchronize() function to acheive
> that. The underscores are to emphasis the low level aspect of it and
> to discourage driver writers who don't know what they are doing to
> use it (to please DaveM :-)

And I forgot to remove that bit from the description... as pointed out
by Josh. Grrr...

Ben.


