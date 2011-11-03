From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 0/2] clean up tx_bytes accounting
Date: Thu, 03 Nov 2011 15:27:38 +0100
Message-ID: <4EB2A4DA.6040800@hartkopp.net>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT> <1320313675-30749-1-git-send-email-mkl@pengutronix.de> <20111103100333.GD317@e-circ.dyndns.org> <4EB27026.90301@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Reuben.Dowle@navico.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:12578 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754462Ab1KCO2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 10:28:00 -0400
In-Reply-To: <4EB27026.90301@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.11.2011 11:42, Marc Kleine-Budde wrote:

> On 11/03/2011 11:03 AM, Kurt Van Dijck wrote:
>> On Thu, Nov 03, 2011 at 10:47:53AM +0100, Marc Kleine-Budde wrote:
>>> Hello,
>>>
>>> what about turning can_get_echo_skb() into a helper function which returns the number
>>> of tx'ed bytes.
>> That would work.
>>
>> Next step would be to do the statistics inside can_get_echo_skb(), but that's
>> affecting all drivers using it ...
>> Kurt
> 
> Interesting idea


Yes, but then the name of the function is not appropriate anymore.

The return value for can_get_echo_skb() gives a silent improvement that can be
adopted by CAN drivers by the time. But hiding more functionality inside this
function may lead to misunderstandings.

Regards,
Oliver
