From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec] xfrm: Fix installation of AH IPsec SAs
Date: Mon, 30 Jun 2014 11:27:46 +0200
Message-ID: <20140630092745.GQ32371@secunet.com>
References: <53AC1C4D.3080305@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Fan Du <fan.du@windriver.com>,
	Andreas Steffen <andreas.steffen@strongswan.org>
To: Tobias Brunner <tobias@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58740 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726AbaF3J14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2014 05:27:56 -0400
Content-Disposition: inline
In-Reply-To: <53AC1C4D.3080305@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2014 at 03:12:45PM +0200, Tobias Brunner wrote:
> The SPI check introduced in ea9884b3acf3311c8a11db67bfab21773f6f82ba
> was intended for IPComp SAs but actually prevented AH SAs from getting
> installed (depending on the SPI).

Yes, this patch was apparently wrong.

> 
> Fixes: ea9884b3acf3 ("xfrm: check user specified spi for IPComp")
> Cc: Fan Du <fan.du@windriver.com>
> Signed-off-by: Tobias Brunner <tobias@strongswan.org>

Applied to the ipsec tree, thanks a lot Tobias!
