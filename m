From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Mon, 25 Jun 2007 19:29:36 +0200
Message-ID: <467FFB80.8070405@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32903179977@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42899 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbXFYRaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 13:30:22 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903179977@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>
>> And RTA_PUT_FLAG. Now that I think of it, does it even makes 
>> sense to have a prio private flag for this instead of a qdisc 
>> global one?
>>     
>
> There currently aren't any other qdiscs that are natural fits for
> multiqueue that I can see.  I can see the benefit though of having this
> as a global flag in the qdisc API; let me check it out, and if it makes
> sense, I can move it.
>   

Yes, that thought occured to me as well. Keeping it private
seems better.


