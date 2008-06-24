From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH v2 2/2] [iproute2/tc] hfsc: add link layer overhead
	adaption
Date: Tue, 24 Jun 2008 22:58:50 +0300
Message-ID: <20080624225850.nvasycyghwko8k8o@hayate.ip6>
References: <20080624085514.22540.91038.stgit@fate.lan>
	<20080624085519.22540.40534.stgit@fate.lan>
	<4860C910.4050703@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@osdl.org>
To: lists@andyfurniss.entadsl.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:39603 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbYFXT6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 15:58:53 -0400
In-Reply-To: <4860C910.4050703@andyfurniss.entadsl.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Andy Furniss <lists@andyfurniss.entadsl.com>:

> Jussi Kivilinna wrote:
>> Patch adds 'mpu', 'mtu', 'overhead' and 'linklayer' options to hfsc. These
>> options are used to create size table for sch_hfsc. Size table is only used
>> and passed to kernel if these options are used.
>
>> +	unsigned short overhead = 0, mpu = 0;
>
> overhead may need to be negative because skb->len on eth is payload + 14
>
> Andy.

Ok, I made size tables use signed short for overhead instead. But this  
makes me think should htb/cfq/tfb be changed to support negative  
overhead too? Rate table they use have unsigned overhead.

  - Jussi


