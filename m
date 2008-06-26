From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH v2 2/2] [iproute2/tc] hfsc: add link layer overhead
	adaption
Date: Fri, 27 Jun 2008 02:31:42 +0300
Message-ID: <20080627023142.g4lopi8l8g8kw8kw@hayate.ip6>
References: <20080624085514.22540.91038.stgit@fate.lan>
	<20080624085519.22540.40534.stgit@fate.lan>
	<4860C910.4050703@andyfurniss.entadsl.com>
	<20080624225850.nvasycyghwko8k8o@hayate.ip6> <486226F2.60703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: lists@andyfurniss.entadsl.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:52022 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbYFZXbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 19:31:44 -0400
In-Reply-To: <486226F2.60703@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Patrick McHardy <kaber@trash.net>:

> Jussi Kivilinna wrote:
>> Quoting Andy Furniss <lists@andyfurniss.entadsl.com>:
>>
>>> Jussi Kivilinna wrote:
>>>> Patch adds 'mpu', 'mtu', 'overhead' and 'linklayer' options to hfsc. These
>>>> options are used to create size table for sch_hfsc. Size table is  
>>>>  only used
>>>> and passed to kernel if these options are used.
>>>
>>>> +    unsigned short overhead = 0, mpu = 0;
>>>
>>> overhead may need to be negative because skb->len on eth is payload + 14
>>>
>>> Andy.
>>
>> Ok, I made size tables use signed short for overhead instead.
>
> Please wait with resending until I get a chance to review the
> patches (probably later today) in case something else comes up.

Ok.




