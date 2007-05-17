From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when
 real-servers are removed
Date: Thu, 17 May 2007 13:51:22 -0700 (PDT)
Message-ID: <20070517.135122.88477511.davem@davemloft.net>
References: <4649DBB7.3070608@trash.net>
	<Pine.LNX.4.58.0705160012470.2626@u.domain.uli>
	<464C857C.9070406@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, horms@verge.net.au, jkrzyszt@tis.icnet.pl,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46450
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755149AbXEQUvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 16:51:21 -0400
In-Reply-To: <464C857C.9070406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 17 May 2007 18:40:28 +0200

> In any case some better solution than the current one needs to be
> found, allowing users to send spoofed packets is far worse than
> using a non-desired source address for ICMP packets.

Agreed, but it only occurs if the nonlocal bind sysctl is
enabled and almost nobody turns that thing on :-)
