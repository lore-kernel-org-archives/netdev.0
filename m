From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPv4 Multicast: prevent reception of mcast frames from	unjoined
 groups
Date: Fri, 11 Jul 2008 10:16:41 -0700
Message-ID: <OF6F2387F9.1EAA3BCD-ON88257483.005E2CF9-88257483.005EE681@us.ibm.com>
References: <20080711152112.GA4534@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, jmorris@namei.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, nhorman@tuxdriver.com,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:33934 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245AbYGKRQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 13:16:52 -0400
In-Reply-To: <20080711152112.GA4534@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 07/11/2008 08:21:13 AM:

> The current ipv4 multicast code incorrectly allows frames destined to 
any
> multicast group to be received on any socket that is bound to 
INADDR_ANY,
> regardless of weather or not that socket is subscribed to that group.

NACK. As Alexey already quoted from me, multicasting just doesn't work
that way, since the beginning of time.

                                                                +-DLS

