From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v3 net-next 2/2] netem: add cell concept to simulate  special MAC behavior
Date: Thu, 01 Dec 2011 10:36:56 +0100
Message-ID: <61abe6ff1aa870d1b885ce88814920d4@localhost>
References: <1322691627-20551-1-git-send-email-hagen@jauu.net>
 <1322691627-20551-2-git-send-email-hagen@jauu.net>
 <1322710225.2577.1.camel@edumazet-laptop>
 <cfd2e2c26063da002d8afe76991ff0c1@localhost>
 <1322730108.2335.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:45880 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751825Ab1LAJg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 04:36:57 -0500
In-Reply-To: <1322730108.2335.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 01 Dec 2011 10:01:48 +0100, Eric Dumazet wrote:



> Yes :)



damn!



> I want to be able to use netem on a 10Gigabit link, and simulate a 5ms

> delay. I already will hit the shared qdisc bottleneck, dont force me to

> use small packets !



No I don't want that. But with 10Gb/s links you will have packet

scheduling problems anyway - if you focus on an _accurate_ delay. A static

delay differs from rate shaping in use case. In the later we (and probably

you) want a exact/realistic spacing between packets.



Due to timer and scheduling granularity somewhere in between 1bit/s and

10Gb/s netem rate (and tbf) will not scale anymore. You will see burst and

inaccurate spacings, far away from what you want to emulate. For us we want

a realistic and clean behavior, if the result of the emulation is not

identical to the emulated link/device we cannot use it (some background

information). 



Anyway: I was not sure what solution you prefer - for us both are

identical. That's why I presented two solutions, so you can pick up the

favorite one. I will re-code the calculation using a reciprocal divide.

Thanks Eric!



Hagen
