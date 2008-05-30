From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH net-next] IPv6 address labels per namespace - v2
Date: Fri, 30 May 2008 15:03:11 +0200
Message-ID: <483FFB0F.7050303@bull.net>
References: <20080528125114.372886409@theryb.frec.bull.fr>	<20080528125137.228283589@theryb.frec.bull.fr> <20080529.163909.07573021.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?windows-1252?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:33150 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbYE3NCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 09:02:47 -0400
In-Reply-To: <20080529.163909.07573021.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / ???? wrote:
> In article <20080528125137.228283589@theryb.frec.bull.fr> (at Wed, 28 May 2008 14:51:24 +0200), Benjamin Thery <benjamin.thery@bull.net> says:
> 
>> This pacth makes IPv6 address labels per network namespace.
>> It keeps the global label tables, ip6addrlbl_table, but 
>> adds a 'net' member to each ip6addrlbl_entry.
>> This new member is taken into account when matching labels.
>>
>> Changelog
>> =========
>> * v1: Initial version 
>> * v2:
>>   * Minize the penalty when network namespaces are not configured:
>>       *  the 'net' member is added only if CONFIG_NET_NS is 
>>          defined. This saves space when network namespaces are not 
>>          configured.
>>       * 'net' value is retrieved with the inlined function 
>>          ip6addrlbl_net() that always return &init_net when 
>>          CONFIG_NET_NS is not defined.
>>   * 'net' member in ip6addrlbl_entry renamed to the less generic 
>>     'lbl_net' name (helps code search).
>>
>> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
> 
> I'm going to apply this.  Thank you.

Great.
Will you apply it to your own IPv6 tree or net-next-2.6?

--Benjamin
> 
> --yoshfuji
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
