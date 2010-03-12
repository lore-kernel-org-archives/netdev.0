From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Fri, 12 Mar 2010 12:18:05 +0100
Message-ID: <m3tyslyej6.fsf@ursa.amorsen.dk>
References: <4B4CE2B8.1040702@redfish-solutions.com>
	<20100112.130355.144803575.davem@davemloft.net>
	<4B9943A4.8040606@redfish-solutions.com>
	<20100311.112941.177105216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: philipp_subx@redfish-solutions.com,
	torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:42967 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932463Ab0CLLSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Mar 2010 06:18:46 -0500
In-Reply-To: <20100311.112941.177105216.davem@davemloft.net> (David Miller's
	message of "Thu, 11 Mar 2010 11:29:41 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Look, this doesn't work.  QoS handling and policy belongs in the
> egress point to the network, it's the only way to control this
> properly and prevent abuse.

First, QoS is important even within the network. Modern switches come
pre-configured with sane defaults which ensure that e.g. EF marked
packets get priority over non-EF-marked packets. Cisco, HP, and
Linksys-Cisco at least provide a decent out-of-the-box configuration.

This can obviously be abused, but the solution there is the same as in
network abuses: Either apply the LART or change the configuration of the
switches to be less trusting. We haven't, so far, had a customer where
the LART was necessary, much less had to reconfigure a switch.

So why not let Linux provide the same out-of-the-box experience as the
switches do? If the trust is abused Linux provides lots of tools to make
it less trusting or even to punish the abusers.


/Benny
