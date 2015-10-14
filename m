From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] net: ipv6: Make address flushing on ifdown
 optional
Date: Wed, 14 Oct 2015 06:00:07 -0700 (PDT)
Message-ID: <20151014.060007.594576048227764026.davem@davemloft.net>
References: <1444820621.2175377.409880265.37A31E2D@webmail.messagingengine.com>
	<20151014.051814.801287755321309990.davem@davemloft.net>
	<1444824845.2190190.409937049.5F844219@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, dsa@cumulusnetworks.com,
	netdev@vger.kernel.org, hannes@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753421AbbJNMoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 08:44:04 -0400
In-Reply-To: <1444824845.2190190.409937049.5F844219@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 14 Oct 2015 14:14:05 +0200

> I can bring up the rp_filter setting, too. It currently gets
> unconditional set to strict mode in systemd on all interfaces.

Sigh...

> The question is, if we should care about people enabling forwarding by
> simply toggling the sysctl forwarding knob? Essentially in the kernel we
> could provide two sysctl knobs, one for forwarding and one for local
> reception. So people following the guidelines how to enable forwarding
> could automatically have rp_filter enabled while host mode does not
> because we leave  the forwarding rp_filter setting enabled. This at the
> same time seems unnecessary complex and maybe we should simply talk to
> distributions. ;)
> 
> What do you think?

We could make rp_filter only apply when something more than default and
subnet routes are configured.  Another bypass might be when only one
interface other than loopback is up and enabled for ipv4.
