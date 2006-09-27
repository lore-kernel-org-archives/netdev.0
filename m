From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: mii-tool gigabit support.
Date: Wed, 27 Sep 2006 12:32:38 -0700
Message-ID: <451AD1D6.4030708@intel.com>
References: <20060926145113.7a6791c8@freekitty> <4519A1D6.1050802@pobox.com> <Pine.LNX.4.64.0609271215150.2299@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	dhinds@pcmcia.sourceforge.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23560 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1030688AbWI0Tem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 15:34:42 -0400
To: dean gaudet <dean@arctic.org>
In-Reply-To: <Pine.LNX.4.64.0609271215150.2299@twinlark.arctic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dean gaudet wrote:
> On Tue, 26 Sep 2006, Jeff Garzik wrote:
> 
>> Stephen Hemminger wrote:
>>> The mii-tool utility seems to be abandoned and unmaintained?
>>>
>>> Here is a version that does standard 1000baseT support.
>>> 	http://developer.osdl.org/shemminger/prototypes/mii-tool.tar.bz2
>> Not really.  I would rather leave it as-is, and deprecate it in favor of
>> ethtool.
> 
> is there some ethtool (version 5) option i'm missing that will give a nice 
> concise link negotation state report like mii-tool does?

how about `ethtool ethX` ? It doesn't report what happened during negotiotion 
but it shows status and advertised/autonegotiated/supported modes

> on e1000 it seems i can find this info only via the -d option, which dumps 
> a lot of other info.
> 
> on skge -d doesn't seem to dump the negotiation state.
> 
> on tg3 -d doesn't even interpret the registers...
> 
> maybe it's just that i haven't had caffeine but i think i've tried every 
> reporting option i can find on the man page and can't find link 
> negotiation state.

dumping registers in readable format is an extension that needs to be 
implemented per driver. Not all nics have done this - we just did it ourselves 
for ixgb, and I saw skge/sky2 just fly by this week.

Cheers,

Auke

> 
> -dean
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
