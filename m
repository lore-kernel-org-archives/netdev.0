From: David Miller <davem@davemloft.net>
Subject: Re: netlink NETLINK_ROUTE failure & Can the kernel really handle
 IPv6 properly
Date: Fri, 03 Oct 2014 11:49:49 -0700 (PDT)
Message-ID: <20141003.114949.826855678619123407.davem@davemloft.net>
References: <9330C415-574C-492B-A7AE-92EBCF6D1A26@emagii.com>
	<1412264648.7227.9.camel@dcbw.local>
	<542E576B.50708@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, netdev@emagii.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: ulf.samuelsson@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753103AbaJCSrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 14:47:46 -0400
In-Reply-To: <542E576B.50708@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Date: Fri, 3 Oct 2014 09:59:39 +0200

> The kernel module is a control module which collects information
> both from the kernel and from H/W, and talks to a userspace interface
> manager.
> 
> There is a proprietary management application which is used to
> configure the stack.
> This talks to the interface manager to handle different operations for
> IPv6.
> 
> The kernel module needs to know when interfaces are ready to use,
> I.E: know when it exits "tentative" mode to do its job properly,
> so the kernel module has to listen for RTM_NEWADDR.
> 
> In a simpler system, your approach would be OK.

Sorry, we're not going to help you with a proprietary driver
of this kind.

They should really just follow our upstream efforts to design
a usable kernel framework for bridge and routing hardware offloads.
