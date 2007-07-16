From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Mon, 16 Jul 2007 15:07:25 +0200
Message-ID: <469B6D8D.1030809@trash.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de>	<467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net>	<467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net>	<467D4965.40601@trash.net> <467D4D65.2080806@hartkopp.net>	<467D54AB.5010407@trash.net> <ygfzm2ciemk.fsf@janus.isnogud.escape.de>	<468BA83A.7070500@trash.net> <ygfodil7qpi.fsf@janus.isnogud.escape.de> <469243D3.3090208@trash.net> <469253CE.8040004@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	j.hadi123@gmail.com, netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49865 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755744AbXGPNI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 09:08:57 -0400
In-Reply-To: <469253CE.8040004@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> Patrick McHardy wrote:
> 
>>Still configuration of the network device based on module parameters.
>>What about people that want loopback and non-loopback devices at the
>>same time?
>>  
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


So its the "correct" handling and the other one is only fallback? That
still sounds like it wants proper configuration. How does loopback work
without this driver?
