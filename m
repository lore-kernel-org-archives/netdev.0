From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: deprecate print_mac
Date: Wed, 15 Jul 2009 11:31:56 -0700 (PDT)
Message-ID: <20090715.113156.120453022.davem@davemloft.net>
References: <1247671403.10754.8.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41632
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755198AbZGOSbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 14:31:52 -0400
In-Reply-To: <1247671403.10754.8.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 15 Jul 2009 17:23:23 +0200

> We've had %pM for long enough now, time to deprecate
> print_mac() and remove the __maybe_unused attribute
> from DECLARE_MAC_BUF so that variables declared with
> that can be found and removed. Otherwise people are
> putting in new users of print_mac().
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> ---
> On my tree, with three other patches I have submitted
> to gianfar, fcoe and wireless, there's now no user of
> DECLARE_MAC_BUF() left. I'm open to just killing it
> right away, but that seems like a pain to coordinate
> and would likely get merge conflicts, so this is much
> simpler and then killing it next cycle.

I think I'm going to apply this after John's next
wireless merge to me for net-next-2.6
