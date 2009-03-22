From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] sfc: Implement adaptive IRQ moderation
Date: Sat, 21 Mar 2009 19:10:07 -0700 (PDT)
Message-ID: <20090321.191007.67420942.davem@davemloft.net>
References: <1237591540.3217.6.camel@achroite>
	<1237591837.3217.17.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59981
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752831AbZCVCKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 22:10:20 -0400
In-Reply-To: <1237591837.3217.17.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 20 Mar 2009 23:30:37 +0000

> Calculate a score for each 1000 IRQs:
> - TX completions are worth 1 point
> - RX completions are worth 4 if merged using LRO or 2 otherwise
> 
> Reduce moderation if the score is less than 10000, down to a minimum
> of 5 us.  Increase moderation if the score is more than 20000, up to
> the specified maximum.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
