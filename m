From: David Miller <davem@davemloft.net>
Subject: Re: [re-resend] [PATCH 2.6.25] BNX2X: prevent ethtool setting of
 port type
Date: Thu, 20 Mar 2008 15:56:53 -0700 (PDT)
Message-ID: <20080320.155653.02440497.davem@davemloft.net>
References: <1205832997.8232.391.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44287
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755273AbYCTW4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 18:56:37 -0400
In-Reply-To: <1205832997.8232.391.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Tue, 18 Mar 2008 11:36:37 +0200

> BNX2X: prevent ethtool setting of port type
> 
> On 10GBaseT boards setting the type to TP will cause the driver to try
> to configure 1GBaseT.
> Since there are currently no boards that support setting of the port
> type, disable this for now.
> 
> Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>

Your email client is still wrapping long lines, so the patch
is corrupt (again), please fix this.

> @@ -8008,38 +8008,6 @@ static int bnx2x_set_settings(struct net_device
> *dev, struct ethtool_cmd *cmd)
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

That's the wrapped line.
