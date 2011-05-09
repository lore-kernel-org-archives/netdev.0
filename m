From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] ethtool: Add 20G bit definitions
Date: Mon, 09 May 2011 13:50:48 +0100
Message-ID: <1304945448.4065.25.camel@localhost>
References: <1304407809.2518.1.camel@lb-tlvb-dmitry>
	 <20110508.154312.229736305.davem@davemloft.net>
	 <1304936217.32472.10.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50952 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882Ab1EIMuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 08:50:54 -0400
In-Reply-To: <1304936217.32472.10.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-09 at 13:16 +0300, Yaniv Rosner wrote:
> On Sun, 2011-05-08 at 15:43 -0700, David Miller wrote:
> > From: "Yaniv Rosner" <yanivr@broadcom.com>
> > Date: Tue, 3 May 2011 10:30:08 +0300
> > 
> > > Add 20G supported and advertising bit definitions.
> > > 20G will be supported with the 57840 chips.
> > > 
> > > 
> > > Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> > > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> > 
> > Applied to net-next-2.6, thanks.
> > 
> Ben,
> Please note that I haven't added new definition for 20000 link speed
> because my understanding is that it no longer required.
> Let me know if you think it is required, mainly for the speed
> extension in the ethtool application.

There is no need (yet) for specific support of the speed.  However you
should provide a patch for ethtool to make it report these flags in the
advertised/lp_advertised/supported masks.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

