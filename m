From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: allow rejecting with "source address failed policy"
Date: Fri, 07 Jun 2013 15:27:30 -0700 (PDT)
Message-ID: <20130607.152730.1116898639369296832.davem@davemloft.net>
References: <1370270708-24398-1-git-send-email-jogo@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: jogo@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab3FGW1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 18:27:31 -0400
In-Reply-To: <1370270708-24398-1-git-send-email-jogo@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Gorski <jogo@openwrt.org>
Date: Mon,  3 Jun 2013 16:45:08 +0200

> RFC6204 L-14 requires rejecting traffic from invalid addresses with
> ICMPv6 Destination Unreachable, Code 5 (Source address failed ingress/
> egress policy) on the LAN side, so add an appropriate rule for that.
> 
> Signed-off-by: Jonas Gorski <jogo@openwrt.org>

I don't see the point of this, there is no difference from the
existing PROHIBIT other than the error code.  Everything that needs to
be expressed can be done using PROHIBIT.
