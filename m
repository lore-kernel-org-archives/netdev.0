From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: Prevent dev_close/cp_interrupt race on MTU
 change
Date: Wed, 19 Dec 2012 14:31:33 -0800 (PST)
Message-ID: <20121219.143133.1014918366601985306.davem@davemloft.net>
References: <1355946468-3290-1-git-send-email-jogreene@redhat.com>
	<20121219.124014.891279563982531558.davem@davemloft.net>
	<1355950547.18919.93.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jogreene@redhat.com, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062Ab2LSWbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 17:31:36 -0500
In-Reply-To: <1355950547.18919.93.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 19 Dec 2012 20:55:47 +0000

> On Wed, 2012-12-19 at 12:40 -0800, David Miller wrote:
>> You sent this as a "request for testing" last week, but I saw
>> no testing on real hardware whatsoever.
> 
> Thanks for the reminder :)
> 
> Seems to work fine here. I haven't confirmed whether I actually see the
> race or not but changing MTU on a live device works fine, even when it's
> being ping-flooded.
> 
> Tested-by: David Woodhouse <David.Woodhouse@intel.com>

That's more like it, applied, thanks everyone. :-)
