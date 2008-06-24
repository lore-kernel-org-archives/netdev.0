From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [PATCH v2 2/2] [iproute2/tc] hfsc: add link layer overhead	adaption
Date: Tue, 24 Jun 2008 22:39:24 +0100
Message-ID: <4861698C.3040007@andyfurniss.entadsl.com>
References: <20080624085514.22540.91038.stgit@fate.lan>	<20080624085519.22540.40534.stgit@fate.lan>	<4860C910.4050703@andyfurniss.entadsl.com> <20080624225850.nvasycyghwko8k8o@hayate.ip6>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@osdl.org>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:57978 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753147AbYFXVj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 17:39:29 -0400
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
> Ok, I made size tables use signed short for overhead instead. But this 
> makes me think should htb/cfq/tfb be changed to support negative 
> overhead too? Rate table they use have unsigned overhead.

Yea they should really, somehow - eventually :-) It was discussed here -

http://news.gmane.org/find-root.php?group=gmane.linux.network&article=90386

Andy.
