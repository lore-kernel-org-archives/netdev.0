From: David Miller <davem@davemloft.net>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 02:07:02 -0800 (PST)
Message-ID: <20110118.020702.115924992.davem@davemloft.net>
References: <4D336050.9030602@netfilter.org>
	<20110118093811.GA7520@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, arthur.marsh@internode.on.net,
	jengelh@medozas.de, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	hadi@cyberus.ca
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60724
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753239Ab1ARKG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 05:06:28 -0500
In-Reply-To: <20110118093811.GA7520@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 18 Jan 2011 09:38:11 +0000

> Even if I'm wrong, this change added to stable will break many configs.
> My proposal is to revert commit 0ab03c2b147 until proper fix is found.

The flag combination is, at best ambiguous, it has no proper
definition without the check we added.
