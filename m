From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: encx24j600: quiet logging noise on open
Date: Wed, 18 Nov 2015 13:57:47 -0500 (EST)
Message-ID: <20151118.135747.685702978221008980.davem@davemloft.net>
References: <1447796551-8522-1-git-send-email-jon@ringle.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jringle@gridpoint.com
To: jon@ringle.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754276AbbKRS5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 13:57:49 -0500
In-Reply-To: <1447796551-8522-1-git-send-email-jon@ringle.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jon@ringle.org
Date: Tue, 17 Nov 2015 16:42:31 -0500

> From: Jon Ringle <jringle@gridpoint.com>
> 
> When encx24j600 is open and closed many times due to userspace polling the
> interface, the log gets noise with this log message. Change logging level
> to debug
> 
> Signed-off-by: Jon Ringle <jringle@gridpoint.com>

This should be moved into the probe method instead, as that's where
outputting something like that belongs.
