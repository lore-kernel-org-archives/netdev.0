From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 2/2] [iproute2/tc] hfsc: add link layer overhead	adaption
Date: Wed, 25 Jun 2008 13:07:30 +0200
Message-ID: <486226F2.60703@trash.net>
References: <20080624085514.22540.91038.stgit@fate.lan>	<20080624085519.22540.40534.stgit@fate.lan>	<4860C910.4050703@andyfurniss.entadsl.com> <20080624225850.nvasycyghwko8k8o@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lists@andyfurniss.entadsl.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50132 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754335AbYFYLHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 07:07:35 -0400
In-Reply-To: <20080624225850.nvasycyghwko8k8o@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> Quoting Andy Furniss <lists@andyfurniss.entadsl.com>:
> 
>> Jussi Kivilinna wrote:
>>> Patch adds 'mpu', 'mtu', 'overhead' and 'linklayer' options to hfsc. 
>>> These
>>> options are used to create size table for sch_hfsc. Size table is 
>>> only used
>>> and passed to kernel if these options are used.
>>
>>> +    unsigned short overhead = 0, mpu = 0;
>>
>> overhead may need to be negative because skb->len on eth is payload + 14
>>
>> Andy.
> 
> Ok, I made size tables use signed short for overhead instead.

Please wait with resending until I get a chance to review the
patches (probably later today) in case something else comes up.
