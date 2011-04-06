From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 3/9] tg3: Reintroduce 5717_PLUS
Date: Wed, 06 Apr 2011 11:28:27 -0700 (PDT)
Message-ID: <20110406.112827.104052812.davem@davemloft.net>
References: <1302049371-13799-4-git-send-email-mcarlson@broadcom.com>
	<1302067853.1683.29.camel@Joe-Laptop>
	<20110406173325.GA14870@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41292
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755368Ab1DFS3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 14:29:04 -0400
In-Reply-To: <20110406173325.GA14870@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 6 Apr 2011 10:33:26 -0700

> For the record though, I did consider using the TG3_FLG3_5717_PLUS flag.
> I'm uncomfortable with using it here because this is more of a server
> class device feature.  Should another mobile or desktop device be
> created in the future, I'd have to devise this type of flag to identify
> what feature I'm really talking about.  I thought it prudent to just
> take care of that now.
> 
> (Not that this is a compelling argument, but it also is a handy way to
> enable and disable the feature while debugging.)

I think the current approach is fine, getting these feature tests right
is indeed non-trivial :-)

I'll apply this patch series to net-next-2.6 and if some tweaks are
still desired, please send them as follow-up patches.

Thanks!
