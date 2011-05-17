From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sfc: Replace enum efx_fc_type with macros
 and type alias
Date: Tue, 17 May 2011 17:45:17 -0400 (EDT)
Message-ID: <20110517.174517.1947013680959781158.davem@davemloft.net>
References: <1305666379.2848.45.camel@bwh-desktop>
	<20110517.171412.1017451005914294196.davem@davemloft.net>
	<1305668611.2848.58.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932426Ab1EQVpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:45:21 -0400
In-Reply-To: <1305668611.2848.58.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Too late Ben, I've already written this patch myself using "u8"
throughout since that also matches the return type of the mii_*()
routines that feed this value.
