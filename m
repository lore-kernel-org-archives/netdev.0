From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sat, 23 Jun 2007 19:13:15 +0200
Message-ID: <467D54AB.5010407@trash.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de> <467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net> <467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net> <467D4965.40601@trash.net> <467D4D65.2080806@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, j.hadi123@gmail.com,
	Urs Thuermann <urs@isnogud.escape.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56922 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877AbXFWRNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 13:13:31 -0400
In-Reply-To: <467D4D65.2080806@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> Patrick McHardy wrote:
> 
>>BTW, in case the loopback device is required for normal
>>operation it might make sense to create *one* device by
>>default, but four identical devices seems a bit extreme.
>
> 
> As i wrote before CAN addressing consists of CAN-Identifiers and the
> used interface. The use of four vcan's is definitely a usual case!


It should create as many devices as necessary to operate (similar
to the loopback device) by default. Optional interfaces that are
used for addressing reasons should be manually added by the user
as needed. And it should not use module parameters for that please.
