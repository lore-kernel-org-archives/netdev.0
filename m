From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Re: SFQ depth limit
Date: Thu, 24 Jul 2008 10:45:39 +0200
Message-ID: <48884133.8070301@trash.net>
References: <200806282202.59581.denys@visp.net.lb>	<20080629191113.GA8817@ami.dom.local> <20080723.213443.37820788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, denys@visp.net.lb, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61071 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbYGXIq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 04:46:29 -0400
In-Reply-To: <20080723.213443.37820788.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 29 Jun 2008 21:11:13 +0200
>
>   
>> sch_sfq: dump a real number of flows
>>
>> Dump the "flows" number according to the number of active flows
>> instead of repeating the "limit".
>>     
>
> Looks reasonable, applied, thanks Jarek.

I'm not sure we should do this, this removes the symetry between
->init/change and ->dump. Its not a big deal in this case since
flows is unused in ->init anyway, but still its a not so nice
precedent. Such things should normally be put in the statistics.

