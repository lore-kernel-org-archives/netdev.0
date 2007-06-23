From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sat, 23 Jun 2007 18:42:13 +0200
Message-ID: <467D4D65.2080806@hartkopp.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de> <467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net> <467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net> <467D4965.40601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, j.hadi123@gmail.com,
	Urs Thuermann <urs@isnogud.escape.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:29877 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755084AbXFWQmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 12:42:55 -0400
In-Reply-To: <467D4965.40601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
>
> BTW, in case the loopback device is required for normal
> operation it might make sense to create *one* device by
> default, but four identical devices seems a bit extreme.
>
>   

As i wrote before CAN addressing consists of CAN-Identifiers and the
used interface. The use of four vcan's is definitely a usual case!

Oliver


