From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V2 03/16] net: fec: pass txq to fec_enet_tx_queue
 instead of queue_id
Date: Tue, 1 Mar 2016 15:43:01 -0700
Message-ID: <56D61AF5.5030507@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-4-git-send-email-troy.kisky@boundarydevices.com>
 <CAHrpEqSyuToC6QFEZygO0YyA=gV2cZEtkpRJMeZFOjhgTLdexQ@mail.gmail.com>
 <56D60EDE.7090100@boundarydevices.com>
 <CAHrpEqQdBqUwfrHL=dHGszEeU-pRo9mmOyuTy6aaw3QMBdkqUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
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
To: Zhi Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35258 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbcCAWnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:43:03 -0500
Received: by mail-pa0-f48.google.com with SMTP id bj10so51059254pad.2
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 14:43:03 -0800 (PST)
In-Reply-To: <CAHrpEqQdBqUwfrHL=dHGszEeU-pRo9mmOyuTy6aaw3QMBdkqUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/2016 3:26 PM, Zhi Li wrote:
> On Tue, Mar 1, 2016 at 3:51 PM, Troy Kisky
> <troy.kisky@boundarydevices.com> wrote:
>> True, but fec_txq/fec_rxq is called in a loop.
> 
> netdev_priv(ndev) is that pointer move.
> dev + ALIGN(sizeof(struct net_device), NETDEV_ALIGN)
> 
> Modem compiler can handle it greatly.
> 
> You can't get any valuable performance gain by that.
> 
> The main time of CPU is call dma_map_xxx.
> 
> best regards
> Frank Li
> 

Ok, I'll revert that part.
