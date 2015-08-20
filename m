From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] average: convert users to inline implementation
Date: Thu, 20 Aug 2015 14:10:49 -0700 (PDT)
Message-ID: <20150820.141049.1751037490283869226.davem@davemloft.net>
References: <1439970382-6170-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbbHTVKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:10:50 -0400
In-Reply-To: <1439970382-6170-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 19 Aug 2015 09:46:18 +0200

> Since there's very little benefit of the out-of-line implementation
> (a single byte of .text in one driver as far as I've seen), convert
> all drivers to the inline implementation, saving memory, and remove
> the out-of-line implementation.
> 
> Perhaps the easiest would be for Dave to take all of these patches?

Ok, I'll applied this series to net-next, thanks.
