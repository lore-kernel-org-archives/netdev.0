From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [PATCH net-next V2 03/16] net: fec: pass txq to fec_enet_tx_queue
 instead of queue_id
Date: Tue, 1 Mar 2016 16:26:15 -0600
Message-ID: <CAHrpEqQdBqUwfrHL=dHGszEeU-pRo9mmOyuTy6aaw3QMBdkqUg@mail.gmail.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
	<1456360619-24390-4-git-send-email-troy.kisky@boundarydevices.com>
	<CAHrpEqSyuToC6QFEZygO0YyA=gV2cZEtkpRJMeZFOjhgTLdexQ@mail.gmail.com>
	<56D60EDE.7090100@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Duan Fugang-B38611 <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Andrew Lunn <andrew@lunn.ch>,
	Philippe Reynes <tremyfr@gmail.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Laci Tele <laci@boundarydevices.com>,
	Shawn Guo <shawnguo@kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Joshua Clayton <stillcompiling@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Arnd Bergmann <arnd@arndb.de>
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f196.google.com ([209.85.214.196]:33934 "EHLO
	mail-ob0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbcCAW0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:26:16 -0500
Received: by mail-ob0-f196.google.com with SMTP id wz1so13552550obc.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 14:26:15 -0800 (PST)
In-Reply-To: <56D60EDE.7090100@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 3:51 PM, Troy Kisky
<troy.kisky@boundarydevices.com> wrote:
> True, but fec_txq/fec_rxq is called in a loop.

netdev_priv(ndev) is that pointer move.
dev + ALIGN(sizeof(struct net_device), NETDEV_ALIGN)

Modem compiler can handle it greatly.

You can't get any valuable performance gain by that.

The main time of CPU is call dma_map_xxx.

best regards
Frank Li
