From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: cfg80211 take 7
Date: Mon, 09 Oct 2006 13:49:15 +0200
Message-ID: <1160394555.3258.3.camel@ux156>
References: <1160146790.2715.82.camel@ux156>
	 <200610091322.10495.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:39594 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932584AbWJILsm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 07:48:42 -0400
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200610091322.10495.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-10-09 at 13:22 +0200, Stefan Rompf wrote:

> nice work! Is there any possibility to limit the card to a specific band (e.g. 
> 802.11 a/b/g) using cfg80211? I'm asking because I haven't seen code to 
> accomplish this in cfg80211, but I maybe wrong.

Never really thought about that, so the answer for now is "no" :) Should
be easy to add though if we figure out what exactly we want/need.

> Many drivers implement this feature as an iwpriv, and I consider it useful 
> enough (especially when association and roaming is kernel controlled) to 
> justify a generic configuration element.

Yeah, probably makes sense. Though, maybe not just the band but a set of
channels instead?

johannes
