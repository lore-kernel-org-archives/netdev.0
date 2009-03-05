From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] sfc: Fix search for flush completion events
Date: Wed, 04 Mar 2009 17:55:46 -0800 (PST)
Message-ID: <20090304.175546.258611888.davem@davemloft.net>
References: <1236196272.3140.15.camel@achroite>
	<1236196875.3140.32.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752954AbZCEB4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 20:56:01 -0500
In-Reply-To: <1236196875.3140.32.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 04 Mar 2009 20:01:15 +0000

> When flushing queues we disable normal interrupt and event handling and
> poll event queue 0 looking for flush completions.  Unfortunately the
> flush event polling loop fails to move past any other type of event.
> This problem has not been observed in production hardware but appears to
> be a possibility.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
