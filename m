From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: neighbour: Add mcast_resolicit to
 configure the number of multicast resolicitations in PROBE state.
Date: Fri, 20 Mar 2015 21:47:56 -0400 (EDT)
Message-ID: <20150320.214756.635332501662393748.davem@davemloft.net>
References: <20150319.224146.893461080038567220.yoshfuji@yoshifuji-H87MS01.miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yanjun.Zhu@windriver.com,
	ulf.samuelsson@ericsson.com
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbbCUBr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 21:47:58 -0400
In-Reply-To: <20150319.224146.893461080038567220.yoshfuji@yoshifuji-H87MS01.miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Date: Thu, 19 Mar 2015 22:41:46 +0900 (JST)

> We send unicast neighbor (ARP or NDP) solicitations ucast_probes
> times in PROBE state.  Zhu Yanjun reported that some implementation
> does not reply against them and the entry will become FAILED, which
> is undesirable.
> 
> We had been dealt with such nodes by sending multicast probes mcast_
> solicit times after unicast probes in PROBE state.  In 2003, I made
> a change not to send them to improve compatibility with IPv6 NDP.
> 
> Let's introduce per-protocol per-interface sysctl knob "mcast_
> reprobe" to configure the number of multicast (re)solicitation for
> reconfirmation in PROBE state.  The default is 0, since we have
> been doing so for 10+ years.
> 
> Reported-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> CC: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
> Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-next.
