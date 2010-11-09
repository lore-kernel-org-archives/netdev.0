From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Netlink limitations
Date: Tue, 9 Nov 2010 12:58:04 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011091253370.20655@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr> <4CD6DF37.6010800@trash.net> <20101108151635.GA20629@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:45273 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754265Ab0KIL6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Nov 2010 06:58:05 -0500
In-Reply-To: <20101108151635.GA20629@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2010-11-08 16:16, Thomas Graf wrote:
>
>Also, it is not required to pack everything in attributes. Your protocol
>may specify that the whole message payload consists of chained attributes.

Yeah but that does not work well with nla_parse and nfnetlink.c
unserializing the byte stream into a tb[] array.

Does it hurt to not use nfnetlink? The only issue I see is that
af_netlink.c's nl_table is an array, when it should preferably be a
hash or tree if we are going to add more subsystems.
