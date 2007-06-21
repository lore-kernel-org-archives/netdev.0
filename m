From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 21 Jun 2007 20:04:35 +0200
Message-ID: <467ABDB3.8020800@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32903146C4B@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44825 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756993AbXFUSE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 14:04:57 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903146C4B@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>> BTw, couldn't you just merge sch_rr with prio? AFAICT you 
>> only need a new dequeue function, a new struct Qdisc_ops and 
>> a MODULE_ALIAS.
>
> Ok, I have this somewhat working, but need to poll for some help from
> the community.  I used MODULE_ALIAS("sch_rr") in sch_prio.c, and
> modprobe is happily loading sch_prio.ko when I ask for sch_rr.ko.  It
> also recognizes the correct ops struct to associate with the instance of
> the module.  However, when I try to load the qdisc via tc (modified
> version that knows sch_rr), I'm getting No Such File or Directory from
> RTNETLINK.  It's looking for sch_rr.ko, and is bailing.  I've scoured
> the code looking for a reason why, and am drawing a blank.  I'll
> continue looking, but if this sounds familiar to someone who knows how
> to get around this, please reply and let me know.

Please post the code.

