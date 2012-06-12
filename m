From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [patch] can: c_can: precedence error in c_can_chip_config()
Date: Tue, 12 Jun 2012 13:01:19 +0200
Message-ID: <4FD7217F.4050404@hartkopp.net>
References: <20120609155150.GA6488@elgon.mountain> <4FD4DEF2.6070802@pengutronix.de> <4FD62E21.3020209@hartkopp.net> <4FD70DD9.4010009@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	AnilKumar Ch <anilkumar@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <jkosina@suse.cz>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:58205 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145Ab2FLLBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 07:01:21 -0400
In-Reply-To: <4FD70DD9.4010009@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.06.2012 11:37, Marc Kleine-Budde wrote:

> On 06/11/2012 07:42 PM, Oliver Hartkopp wrote:
>> On 10.06.2012 19:52, Marc Kleine-Budde wrote:
>>
>>> On 06/09/2012 05:56 PM, Dan Carpenter wrote:
>>>> (CAN_CTRLMODE_LISTENONLY & CAN_CTRLMODE_LOOPBACK) is (0x02 & 0x01) which
>>>> is zero so the condition is never true.  The intent here was to test
>>>> that both flags were set.
>>>>
>>>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>>> ---
>>>> This is a static checker fix.  I'm not super familiar with the c_can
>>>> code.
>>>
>>> Good catch. Applied to can-next.
>>>
>>> Marc
>>>
>>
>>
>> Shouldn't this fix go through the net-tree and stable instead of net-next?
> 
> Can I add your Acked-by ... when adding to net?


Yes you can :-)

Oliver
