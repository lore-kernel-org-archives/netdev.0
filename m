From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless stack
Date: Mon, 5 Jan 2009 14:36:57 +0100
Message-ID: <20090105133657.GQ496@one.firstfloor.org>
References: <20090104151819.GA6590@basil.nowhere.org> <1231085150.3296.3.camel@johannes> <20090104162826.GT496@one.firstfloor.org> <1231087288.3296.15.camel@johannes> <20090104174339.GX496@one.firstfloor.org> <1231090388.3296.17.camel@johannes> <20090104184136.GY496@one.firstfloor.org> <1231144574.3286.15.camel@johannes> <20090105132141.GO496@one.firstfloor.org> <1231161379.3334.14.camel@johannes>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linville@tuxdriver.com,
	davem <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35812 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888AbZAENXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 08:23:06 -0500
Content-Disposition: inline
In-Reply-To: <1231161379.3334.14.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 05, 2009 at 02:16:19PM +0100, Johannes Berg wrote:
> > I didn't use any monitoring with this. No tcpdump, no wireless
> > sniffer tools or anything. It happened all the time during
> > normal operation.
> 
> You did have a monitor interface up though, didn't you? If nothing

wmaster0 was up. Is that a monitoring interface? 

> actually used those skbs then it's likely that the warning didn't result
> in any corruption at all.

Nothing was corrupted ever to my knowledge, just lots of spam in my kernel logs.

-Andi
-- 
ak@linux.intel.com
