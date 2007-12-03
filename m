From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Mon, 03 Dec 2007 10:29:51 -0800
Message-ID: <47544B1F.1010902@candelatech.com>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill> <474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch> <4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch> <47543E65.4060303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:35122 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160AbXLCSaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 13:30:13 -0500
In-Reply-To: <47543E65.4060303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
>
> That sounds like it would also be possible using rtnetlink. You could
> send out a notification whenever you switch the active buffer and have
> userspace listen to these and replace the inactive one.

Also, I think you will need a larger cache than 4-8k if you are running 
higher speeds (100,000 pps, etc),
as you probably can't rely on user-space responding reliably every 10ms 
(or even less time for faster
speeds.)

Thanks,
Ben

>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


