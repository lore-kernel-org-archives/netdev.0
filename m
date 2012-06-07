From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] snmp: fix OutOctets counter to include forwarded
 datagrams
Date: Thu, 07 Jun 2012 14:53:26 -0700 (PDT)
Message-ID: <20120607.145326.1203419171187480651.davem@davemloft.net>
References: <1338903702-18975-1-git-send-email-bernat@luffy.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: bernat@luffy.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45974 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933057Ab2FGVx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 17:53:26 -0400
In-Reply-To: <1338903702-18975-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <bernat@luffy.cx>
Date: Tue,  5 Jun 2012 15:41:42 +0200

> RFC 4293 defines ipIfStatsOutOctets (similar definition for
> ipSystemStatsOutOctets):
> 
>    The total number of octets in IP datagrams delivered to the lower
>    layers for transmission.  Octets from datagrams counted in
>    ipIfStatsOutTransmits MUST be counted here.
> 
> And ipIfStatsOutTransmits:
> 
>    The total number of IP datagrams that this entity supplied to the
>    lower layers for transmission.  This includes datagrams generated
>    locally and those forwarded by this entity.
> 
> Therefore, IPSTATS_MIB_OUTOCTETS must be incremented when incrementing
> IPSTATS_MIB_OUTFORWDATAGRAMS.
> 
> IP_UPD_PO_STATS is not used since ipIfStatsOutRequests must not
> include forwarded datagrams:
> 
>    The total number of IP datagrams that local IP user-protocols
>    (including ICMP) supplied to IP in requests for transmission.  Note
>    that this counter does not include any datagrams counted in
>    ipIfStatsOutForwDatagrams.
> 
> Signed-off-by: Vincent Bernat <bernat@luffy.cx>

Applied, thanks for the detailed analysis.
