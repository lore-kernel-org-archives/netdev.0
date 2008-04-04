From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Fri, 04 Apr 2008 12:45:44 +0200
Message-ID: <47F606D8.108@trash.net>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain> <47A4FB81.80700@fatooh.org> <47A74FEE.6080103@trash.net> <47EED247.50801@andyfurniss.entadsl.com> <47F22CF5.4080806@trash.net> <47F28758.1010401@andyfurniss.entadsl.com> <47F37139.9080303@andyfurniss.entadsl.com> <47F37E04.4010001@trash.net> <47F3B3C5.6000701@andyfurniss.entadsl.com> <47F6062E.9050804@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: lists@andyfurniss.entadsl.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33093 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667AbYDDKpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 06:45:45 -0400
In-Reply-To: <47F6062E.9050804@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Furniss wrote:
> Andy Furniss wrote:
> 
>> OK - FWIW I've been looking harder and have now seen the full range of 
>> +/- 32k so I assume it's just not getting initialised properly.
> 
> Hmm I am not so sure now maybe it's a stats thing - I have seen flows 
> apparently stuck with -ve allot but behaving normally.
> 
> I notice allot is short (16bits?) in sfq but see
> 
> +struct tc_sfq_xstats
> +{
> +    __s32        allot;
> +};

That doesn't matter, its promoted to a 32 bit value. But now
that you mention it, the SFQ patch for iproute I submitted
used a different type. Stephen has resynced it with the kernel
in the mean time, but you might be using the broken version.


