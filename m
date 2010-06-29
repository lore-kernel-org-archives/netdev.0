From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] ethtool: Fix potential user buffer
 overflow for ETHTOOL_{G,S}RXFH
Date: Tue, 29 Jun 2010 01:01:10 -0700 (PDT)
Message-ID: <20100629.010110.184836313.davem@davemloft.net>
References: <1277750647.2089.19.camel@achroite.uk.solarflarecom.com>
	<1277750759.2089.21.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santwona.behera@sun.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44639
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751069Ab0F2IA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 04:00:57 -0400
In-Reply-To: <1277750759.2089.21.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 28 Jun 2010 19:45:58 +0100

> struct ethtool_rxnfc was originally defined in 2.6.27 for the
> ETHTOOL_{G,S}RXFH command with only the cmd, flow_type and data
> fields.  It was then extended in 2.6.30 to support various additional
> commands.  These commands should have been defined to use a new
> structure, but it is too late to change that now.
> 
> Since user-space may still be using the old structure definition
> for the ETHTOOL_{G,S}RXFH commands, and since they do not need the
> additional fields, only copy the originally defined fields to and
> from user-space.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Cc: stable@kernel.org

Applied.
