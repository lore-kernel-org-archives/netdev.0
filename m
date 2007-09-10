From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Mon, 10 Sep 2007 10:20:15 +0100
Message-ID: <46E50C4F.1070506@katalix.com>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>	 <1189120020.4259.68.camel@localhost>  <46E11A61.9030409@katalix.com> <1189171370.4234.38.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com,
	Stephen Hemminger <shemminger@osdl.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:36980 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbXIJJUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 05:20:19 -0400
In-Reply-To: <1189171370.4234.38.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:

> If the problem i am trying to solve is "reduce cpu use at lower rate",
> then this is not the right answer because your cpu use has gone up.

The problem I'm trying to solve is "reduce the max interrupt rate from 
NAPI drivers while minimizing latency". In modern systems, the interrupt 
rate can be so high that the CPU spends too much time processing 
interrupts, resulting in the system's behavior seen by the user being 
degraded.

Having the poll() called when idle will always increase CPU usage. But 
the feedback you and others are giving encourages me to find a better 
compromise. At the end of the day, it's going to be a trade-off of cpu 
and latency. The trade-off will be different for each hardware system 
and application environment so parameters need to be tunable.

I'll go away and do some tests. I'll post results here for discussion later.

Thanks for your feedback.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

