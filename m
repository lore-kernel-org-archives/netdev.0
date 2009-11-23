From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 5/5] be2net: remove BUG_ON() when be2net
 runs out of mccq wrbs
Date: Mon, 23 Nov 2009 10:46:01 -0800 (PST)
Message-ID: <20091123.104601.63629006.davem@davemloft.net>
References: <20091123080245.GA7836@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38698
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754200AbZKWSpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 13:45:44 -0500
In-Reply-To: <20091123080245.GA7836@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 23 Nov 2009 13:32:45 +0530

> The driver can run out of mccq wrbs when completions don't arrive
> due to an unresponsive card. This must not hit a BUG_ON(); instead
> log a msg and return an error.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
