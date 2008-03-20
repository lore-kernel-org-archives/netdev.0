From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: r8169 driver fails to see IGMPv2 SAP announcements
Date: Thu, 20 Mar 2008 10:17:02 -0700
Message-ID: <OF2A1B6BCC.6EDD542B-ON88257412.005C674C-88257412.005EEFF4@us.ibm.com>
References: <DE885BD6-C428-48D5-90F4-32C9227F256F@lincor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Glen Gray <glen.gray@lincor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:50153 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755498AbYCTRRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 13:17:17 -0400
In-Reply-To: <DE885BD6-C428-48D5-90F4-32C9227F256F@lincor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The SAP announcements are made via IGMPv2, however the eth0 device 
> comes up as IGMPv3 and so doesn't pick up the announcements. I've used 
> the proc interface force_igmp_version to set all devices to v2, but it 
> doesn't seem to make any difference.

Glen,
        I don't really know what you're reporting here. If by "doesn't
seem to make any difference" you mean that you still get v3 reports
when force_igmp_version=2, that would be news to me, and a packet
trace demonstrating that on a mainline kernel would be good.
        If you mean it doesn't fix your data loss problem, then I'd
just conclude that the loss has nothing to do with IGMP reports.

        I think the things of interest to look at are whether the
sender side is sending SAP announcements when the failure occurs and
whether the multicast router ever drops membership when you think
it shouldn't during a failure. You can use "tcpdump" on the sender
side to track these, and your multicast router may have some
logging capability to let you know state changes of interest. I
recommend looking at those (or posting here, size permitting) to
narrow down the problem.

                                                                +-DLS

