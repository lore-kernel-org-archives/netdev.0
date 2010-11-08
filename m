From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Netlink limitations
Date: Mon, 8 Nov 2010 20:21:26 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011081958410.31946@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr> <4CD6DF37.6010800@trash.net> <20101108151635.GA20629@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:46375 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670Ab0KHTVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Nov 2010 14:21:30 -0500
In-Reply-To: <20101108151635.GA20629@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2010-11-08 16:16, Thomas Graf wrote:
>> 
>> Messages are not limited to 64k, individual attributes are. Holger
>> started working on a nlattr32, which uses 32 bit for the length
>> value.
>
>Also, it is not required to pack everything in attributes. Your protocol
>may specify that the whole message payload consists of chained attributes.
>Alternatively you may as well split your attribut chain and dump them
>as several messages.

Yeah with NETLINK_URELEASE that seems the way to go. However, what are
compelling arguments to use Netlink over other forms of bidirectional
communication? (To play devils advocate, one could use nlattr32/TLVs
over ioctl too.)
