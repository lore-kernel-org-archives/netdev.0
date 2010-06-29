From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/2] ethtool: Fix potential kernel buffer
 overflow in ETHTOOL_GRXCLSRLALL
Date: Tue, 29 Jun 2010 01:01:05 -0700 (PDT)
Message-ID: <20100629.010105.55857802.davem@davemloft.net>
References: <1277750647.2089.19.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santwona.behera@sun.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44635
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751069Ab0F2IAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 04:00:54 -0400
In-Reply-To: <1277750647.2089.19.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 28 Jun 2010 19:44:07 +0100

> On a 32-bit machine, info.rule_cnt >= 0x40000000 leads to integer
> overflow and the buffer may be smaller than needed.  Since
> ETHTOOL_GRXCLSRLALL is unprivileged, this can presumably be used for at
> least denial of service.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Cc: stable@kernel.org

Applied.
