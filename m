From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Tue, 04 Dec 2007 09:40:41 -0800
Message-ID: <47559119.6070803@candelatech.com>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:54018 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954AbXLDRkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 12:40:52 -0500
In-Reply-To: <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ariane Keller wrote:
>
> Increasing the cache size to say 32k for each buffer would be no problem.
> Is this enough?
Maybe just a variable length list of 4k buffers chained together?  Its 
usually easier
to get 4k chunks of memory than 32k chunks, especially under high 
network load,
and if you go ahead an make it arbitrary length, then each user can 
determine how many
they want to have queued...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


