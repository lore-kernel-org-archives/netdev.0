From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atmel: fix netdev ops conversion
Date: Tue, 21 Apr 2009 02:09:04 -0700 (PDT)
Message-ID: <20090421.020904.15963653.davem@davemloft.net>
References: <1240304720.17388.13.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37601
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753172AbZDUJJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 05:09:12 -0400
In-Reply-To: <1240304720.17388.13.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 21 Apr 2009 11:05:20 +0200

> sparse says:
> 
> drivers/net/wireless/atmel.c:1501:3: warning: Initializer entry defined twice
> drivers/net/wireless/atmel.c:1505:3:   also defined here
> 
> and it's correct; atmel has its own ndo_change_mtu and
> shouldn't use eth_change_mtu.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> ---
> It looks like you (davem) took the initial conversion, do you want this
> one as well?

Yep, I've got it, applied, thanks Johannes!

