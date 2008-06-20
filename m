From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Separate TSO setup logic.
Date: Thu, 19 Jun 2008 20:07:02 -0700 (PDT)
Message-ID: <20080619.200702.122382220.davem@davemloft.net>
References: <1213931088-8013-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48708
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752294AbYFTDHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 23:07:04 -0400
In-Reply-To: <1213931088-8013-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 19 Jun 2008 20:04:48 -0700

> David, this goes on top of the 3rd patch to manage TX backlog.
> 
> tg3: Separate TSO setup logic.
> 
> Different TG3 chips require slightly different ways of setting up the
> TX descriptor and different initial values for some IP/TCP header
> fields.  It is cleaner to have dedicated TSO setup methods for the
> different chips and to call the proper one using a function pointer.
> The missing logic for TG3_FLG2_HW_TSO_2 has also been added.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Thanks for doing this work michael.

If we put this at the end, it means we have a point in the series
where things are broken, and this makes "git bisect" unusable which
we try to avoid.

Therefore I'll try to integrate this work into my first patch.

Thanks again.
