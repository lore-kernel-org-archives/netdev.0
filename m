From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [CAN] [RFC] skb->iif usage and vcan driver background
Date: Mon, 25 Jun 2007 16:50:00 +0200
Message-ID: <467FD618.2060108@hartkopp.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de> <467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net> <467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net> <467EA11A.7040109@hartkopp.net> <467F9AED.1010309@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: j.hadi123@gmail.com, David Miller <davem@davemloft.net>,
	Urs Thuermann <urs@isnogud.escape.de>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:13612 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640AbXFYOuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 10:50:09 -0400
In-Reply-To: <467F9AED.1010309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
>
> I normally wouldn't have gone reading some PDF to explain a patch,
> but this one was really worth it .. a couple of pictures of cars
> with four applications using can0-can3 :)
>   

This is a really cool insight for car manufacturers employees. If you
miss them out you'll definitely be asked "And where is the car in this
picture?" :-))

> Your last slide brings it to the point: "... configured at module
> load time for the needed use-case:
> - number of created vcan devices (current default=4)
> - perform the loopback on driver level (current default=off)"
>
> So you *do* have parameters for configuration and you're using the
> wrong interface. Either drop them or use the correct interface.
>   

Ok! Got the message!
New vcan with netlink interface coming soon.

Thanks for review & regards,
Oliver


