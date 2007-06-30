From: jamal <hadi@cyberus.ca>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
	Qdisc changes and sch_rr added for multiqueue
Date: Sat, 30 Jun 2007 10:52:44 -0400
Message-ID: <1183215164.5165.13.camel@localhost>
References: <1183121670.5188.16.camel@localhost>
	 <20070629.143102.88475921.davem@davemloft.net>
	 <1183167053.5153.7.camel@localhost>
	 <20070629.213503.34601850.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:26919 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756523AbXF3Ows (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 10:52:48 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1096027wxd
        for <netdev@vger.kernel.org>; Sat, 30 Jun 2007 07:52:47 -0700 (PDT)
In-Reply-To: <20070629.213503.34601850.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-29-06 at 21:35 -0700, David Miller wrote:

> Awesome, but let's concentrate on the client since I can actually
> implement and test anything we come up with :-)

Ok, you need to clear one premise for me then ;->
You said the model is for the guest/client to hook have a port to the
host and one to each guest; i think this is the confusing part for me
(and may have led to the switch discussion) because i have not seen this
model used before. What i have seen before is that the host side
connects the different guests. In such a scenario, on the guest is a
single port that connects to the host - the host worries (lets forget
the switch/bridge for a sec) about how to get packets from guestX to
guestY pending consultation of access control details.
What is the advantage of direct domain-domain connection? Is it a
scalable?

cheers,
jamal

