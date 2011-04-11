From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] niu: Recognise original ethtool class
 code for AH/ESP flow hashing
Date: Mon, 11 Apr 2011 13:29:17 -0700 (PDT)
Message-ID: <20110411.132917.229759117.davem@davemloft.net>
References: <1302306555.2871.59.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
	santwona.behera@sun.com, jeffrey.t.kirsher@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54609
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754937Ab1DKU3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:29:52 -0400
In-Reply-To: <1302306555.2871.59.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 09 Apr 2011 00:49:15 +0100

> When the RX network flow classification interface was originally
> defined for reporting and controlling of flow hashing, AH and ESP were
> not given distinct flow class codes (apparently because the Sun
> Neptune hardware treats them very similarly).
> 
> For flow steering, they must be distinguished, so new and separate
> flow class codes were added for AH and ESP.  But for backward-
> compatibility, flow hash operations should continue to support the
> original class codes.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks Ben.
