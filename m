From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH] netxen: fix LRO disable warning
Date: Mon, 28 Mar 2011 00:33:43 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8849@MNEXMB2.qlogic.org>
References: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com>
	<1300704474.2884.66.camel@edumazet-laptop>
	<99737F4847ED0A48AECC9F4A1974A4B80FD10E8439@MNEXMB2.qlogic.org>
 <20110327.180818.39174806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3.bigfish.com ([94.245.120.74]:57822 "EHLO
	DB3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751025Ab1C1FtY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2011 01:49:24 -0400
In-Reply-To: <20110327.180818.39174806.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> > netxen_nic_set_flags() rejects data if other flag than
> ETH_FLAG_LRO
> >> is set.
> >> > Driver also supports NETIF_F_HW_VLAN_TX.
> >> > Now compare data with ethtool_op_get_flags(), to get all supported
> >> features.
> >> >
> >> > Reported-by: Jesper Dangaard Brouer <jdb@comx.dk>
> >> > Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> >> > Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> >> > ---
> >>
> >> Hmm, it would be really nice you provide more information for stable
> >> teams.
> >>
> >> If I am not mistaken, bug was introduced in 2.6.36 ?
> >>
> > No, It was introduced in 2.6.37, when ETH_FLAG_TXVLAN and
> ETH_FLAG_RXVLAN introduced.
> > Yes it should also make into 2.6.37.4 stable kernel.
>
> Applied, but 2.6.37.x maintainence has ceased so there is no point
> worrying about this patch for that stable branch any longer.

I thought you will apply patch from Stanislaw Gruszka (net: fix ethtool->set_flags not intended -EINVAL return value), which is more generic and takes care of all drivers.

David, you are not cc in that patch. I will forward you, in case you miss it.

-Amit

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

