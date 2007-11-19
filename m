From: David <david@unsolicited.net>
Subject: Re: Netfilter: kernel panic with REDIRECT target. (2.6.23 and 2.6.23.8)
Date: Mon, 19 Nov 2007 19:59:03 +0000
Message-ID: <4741EB07.50706@unsolicited.net>
References: <47408BBC.6040608@unsolicited.net> <200711182131.38388.ismail@pardus.org.tr> <474093E0.3090007@unsolicited.net> <47409863.8000902@trash.net> <4741DB3A.2030304@unsolicited.net> <20071119192423.GA26449@2ka.mipt.ru> <20071119193143.GA12640@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	=?ISO-8859-1?Q?Ismail_D=F6nmez?= <ismail@pardus.org.tr>,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns01.unsolicited.net ([69.10.132.115]:33055 "EHLO
	ns01.unsolicited.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbXKSUAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 15:00:46 -0500
In-Reply-To: <20071119193143.GA12640@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Mon, Nov 19, 2007 at 10:24:23PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
>   
>> On Mon, Nov 19, 2007 at 06:51:38PM +0000, David (david@unsolicited.net) wrote:
>>     
>>> Patrick McHardy wrote:
>>>       
>>>>>>>     iptables -t nat -A PREROUTING -j REDIRECT -i eth2 -p udp --dport
>>>>>>> 5061 --to-ports 5060
>>>>>>>
>>>>>>>         
>>>>>>>               
>>>>>> Also post the kernel panic log.
>>>>>>       
>>>>>>             
>>>> Please try if this patch fixes the problem.
>>>>         
>>> No luck with the patch I'm afraid, panic log attached (of patched kernel).
>>>       
>> Ok, let's try it hard way.
>> Please check attached patch and tell if it helped (it will produce
>> some debug though).
>>     
>
> With both patches applied - one Patrick showed and this one.
>   
Now works, with this in dmesg

conntrack: ea94159c, new: ead4d7c4, old: ead4d7d0, ct: 00000000.

Cheers
David


