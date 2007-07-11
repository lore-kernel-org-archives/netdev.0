From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 11 Jul 2007 21:41:39 +0200
Message-ID: <46953273.2080102@hartkopp.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de>	<467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net>	<467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net>	<467D4965.40601@trash.net> <467D4D65.2080806@hartkopp.net>	<467D54AB.5010407@trash.net> <ygfzm2ciemk.fsf@janus.isnogud.escape.de>	<468BA83A.7070500@trash.net> <ygfodil7qpi.fsf@janus.isnogud.escape.de> <469243D3.3090208@trash.net> <469253CE.8040004@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>, j.hadi123@gmail.com,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:54371 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758513AbXGKTmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 15:42:12 -0400
In-Reply-To: <469253CE.8040004@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

what's your opinion about my reply to your remark?

Should we just change the module parameter from "loopback" to
"loopbacktest" to make the test intention obvious?
Or should we remove the loopback test functionality?

Regards,
Oliver

Oliver Hartkopp wrote:
> Patrick McHardy wrote:
>   
>> Urs Thuermann wrote:
>>   
>>     
>>> (..) To test the handling of CAN
>>> + * interfaces that do not support the loopback both driver types are
>>> + * implemented inside this vcan driver.
>>> (..)
>>>     
>>>       
>> Still configuration of the network device based on module parameters.
>> What about people that want loopback and non-loopback devices at the
>> same time?
>>   
>>     
>
> Hi Patrick,
>
> the people get the loopback functionality in ANY case. There is indeed
> no difference from the view of the users, if you change this switch.
>
> The possibility to enable the loopback on vcan driver level is only to ...
>
> 1. Test the loopback fallback code in af_can.c
> 2. Show, how a correct loopback handling is to be implemented
>
> ... nothing more.
>
> Regarding point 1: The code is well tested now.
> Regarding point 2: Even if code is the best documentation in many cases,
> the loopback functionality may also be 'documented' in another way.
>
> I had a short discussion with Urs about that. Please select:
>
> [ ] Let it like it is
> [ ] Remove the whole loopback functionality (as it is only test code for
> a different module)
> [ ] Remove the module parameter and make it a #define VCAN_LOOPBACK for
> testing
>
> :-)
>
> Thanks & best regards,
> Oliver
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   



