From: Michael Barkowski <michaelbarkowski@ruggedcom.com>
Subject: Re: [PATCH] WAN: flush tx_queue in hdlc_ppp to prevent panic on rmmod
 hw_driver.
Date: Thu, 22 Apr 2010 17:55:41 -0400
Message-ID: <4BD0C5DD.4040304@ruggedcom.com>
References: <m3mxx5mv8v.fsf@intrepid.localdomain>	<4BD0A0B9.2070709@ruggedcom.com> <20100422.144339.128290761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "khc@pm.waw.pl" <khc@pm.waw.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ruggedcom.com ([204.50.148.11]:15635 "EHLO
	mail2.ruggedcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671Ab0DVVzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 17:55:42 -0400
In-Reply-To: <20100422.144339.128290761.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Michael Barkowski <michaelbarkowski@ruggedcom.com>
> Date: Thu, 22 Apr 2010 15:17:13 -0400
> 
>> Krzysztof Halasa wrote:
>>> tx_queue is used as a temporary queue when not allowed to queue skb
>>> directly to the hw device driver (which may sleep). Most paths flush
>>> it before returning, but ppp_start() currently cannot. Make sure we
>>> don't leave skbs pointing to a non-existent device.
>>>
>>> Thanks to Michael Barkowski for reporting this problem.
>> Great - thanks.  Will this be going into -stable?
> 
> When I think it's cooked long enough in Linus's tree and
> I submit it there.  That can take a few weeks.
> 

Super.  By the way, should have mentioned - tested and works for me

-- 
Michael Barkowski
