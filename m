From: Ben Greear <greearb@candelatech.com>
Subject: Re: sending IP pkgs form user space on a specific interface?
Date: Thu, 03 Feb 2011 14:41:07 -0800
Message-ID: <4D4B2F03.60806@candelatech.com>
References: <OFAEE2A3EA.1C3F2C8A-ONC125782C.0077F327-C125782C.007872C6@transmode.se> <4D4B2649.40404@candelatech.com> <OF72446498.F31B6A78-ONC125782C.00794F9B-C125782C.007A2D64@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46759 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab1BCWlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 17:41:11 -0500
In-Reply-To: <OF72446498.F31B6A78-ONC125782C.00794F9B-C125782C.007A2D64@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2011 02:14 PM, Joakim Tjernlund wrote:
> Ben Greear<greearb@candelatech.com>  wrote on 2011/02/03 23:03:53:
>> From: Ben Greear<greearb@candelatech.com>
>> To: Joakim Tjernlund<joakim.tjernlund@transmode.se>
>> Cc: netdev@vger.kernel.org
>> Date: 2011/02/03 23:03
>> Subject: Re: sending IP pkgs form user space on a specific interface?
>>
>> On 02/03/2011 01:55 PM, Joakim Tjernlund wrote:
>>>
>>> Is there a way to specify what I/F a IP pkg should be sent
>>> out on?
>>>
>>> I have multiple ppp I/Fs with the same local and remote address
>>> and I need to specify what interface to send OSPF protocol
>>> messages to.
>>
>> Check out SO_BINDTODEVICE.
>
> Thanks, can do setsockopt(s, SOL_SOCKET, SO_BINDTODEVICE, ..) for
> each I/Fs I need tx pkgs over?
> How do I unbind to any I/F?
>
> If possible, I would like to specify the I/F in the pkg overhead.

Man-pages and google should find those answers.
You could put my name in your search as well, if you want..I know I've
posted sample code in the past to some mailing list or another.

Thanks,
Ben

>
>     Jocke
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

