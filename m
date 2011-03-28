From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: fix LRO disable warning
Date: Sun, 27 Mar 2011 18:08:18 -0700 (PDT)
Message-ID: <20110327.180818.39174806.davem@davemloft.net>
References: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com>
	<1300704474.2884.66.camel@edumazet-laptop>
	<99737F4847ED0A48AECC9F4A1974A4B80FD10E8439@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, rajesh.borundia@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39884
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752553Ab1C1BI5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Mar 2011 21:08:57 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8439@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Amit Salecha <amit.salecha@qlogic.com>
Date: Mon, 21 Mar 2011 06:13:02 -0500

>> Le lundi 21 mars 2011 =E0 03:37 -0700, Amit Kumar Salecha a =E9crit =
:
>> > netxen_nic_set_flags() rejects data if other flag than ETH_FLAG_LR=
O
>> is set.
>> > Driver also supports NETIF_F_HW_VLAN_TX.
>> > Now compare data with ethtool_op_get_flags(), to get all supported
>> features.
>> >
>> > Reported-by: Jesper Dangaard Brouer <jdb@comx.dk>
>> > Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
>> > Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
>> > ---
>>
>> Hmm, it would be really nice you provide more information for stable
>> teams.
>>
>> If I am not mistaken, bug was introduced in 2.6.36 ?
>>
> No, It was introduced in 2.6.37, when ETH_FLAG_TXVLAN and ETH_FLAG_RX=
VLAN introduced.
> Yes it should also make into 2.6.37.4 stable kernel.

Applied, but 2.6.37.x maintainence has ceased so there is no point
worrying about this patch for that stable branch any longer.
