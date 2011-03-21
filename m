From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis purpose.
Date: Mon, 21 Mar 2011 15:19:24 -0700
Message-ID: <4D87CEEC.9000603@candelatech.com>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>	<1300351330.10164.712.camel@edumazet-laptop>	<AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>	<20110317142030.62af785a@nehalam>	<AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>	<1300428324.2881.5.camel@edumazet-laptop>	<AANLkTikrJ7A-ygc9JnkvfBpRaKjL0fKeta+9ASLDr0rg@mail.gmail.com> <20110321141844.25e96184@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47232 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288Ab1CUWTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 18:19:34 -0400
In-Reply-To: <20110321141844.25e96184@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2011 02:18 PM, Stephen Hemminger wrote:
> In case it isn't clear. /proc/net/tcp is a legacy interface and any
> changes to it are certain to be rejected. netlink stats are an extensible
> interface and likely to be accepted.

Might be nice to have this available via

getsockopt(s, 6, /*SOL_TCP,*/ TCP_INFO, (void*)&info, &argsz)
as well.

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

