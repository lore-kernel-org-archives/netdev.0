From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netfilter: kernel panic with REDIRECT target. (2.6.23 and 2.6.23.8)
Date: Tue, 20 Nov 2007 13:11:11 +0100
Message-ID: <4742CEDF.2020102@trash.net>
References: <47408BBC.6040608@unsolicited.net> <200711182131.38388.ismail@pardus.org.tr> <474093E0.3090007@unsolicited.net> <47409863.8000902@trash.net> <4741DB3A.2030304@unsolicited.net> <20071119192423.GA26449@2ka.mipt.ru> <20071119193143.GA12640@2ka.mipt.ru> <4741EB07.50706@unsolicited.net> <20071120115520.GB30752@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David <david@unsolicited.net>,
	=?ISO-8859-15?Q?Ismail_D=F6nmez?= <ismail@pardus.org.tr>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62610 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756762AbXKTMLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 07:11:48 -0500
In-Reply-To: <20071120115520.GB30752@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
>>>> Ok, let's try it hard way.
>>>> Please check attached patch and tell if it helped (it will produce
>>>> some debug though).
>>> With both patches applied - one Patrick showed and this one.
>>>   
>> Now works, with this in dmesg
>>
>> conntrack: ea94159c, new: ead4d7c4, old: ead4d7d0, ct: 00000000.
> 
> David (Miller :), please apply attached patch, which also needed to fix
> netfilter connection tracking bug.
> When connection tracking entry (nf_conn) is about to copy itself it can
> have some of its extension users (like nat) as being already freed and
> thus not required to be copied.
> Frankly saying, it can be not the correct fix, but from code observation
> and test, perfomed by David <david@unsolicited.net> it is.

I also don't believe this can be correct, let me look into this
first.
