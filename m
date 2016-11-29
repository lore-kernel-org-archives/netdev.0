From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: Re: [patch net] net: fec: cache statistics while device is down
Date: Tue, 29 Nov 2016 08:43:17 +0300
Message-ID: <bd33a3da-ae19-151a-6616-dde242f25320@cogentembedded.com>
References: <1480343227-725-1-git-send-email-nikita.yoush@cogentembedded.com>
 <AM4PR0401MB2260081367AC9A140448A631FF8D0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Duan <fugang.duan@nxp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM4PR0401MB2260081367AC9A140448A631FF8D0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  >
>  >+	fec_enet_update_ethtool_stats(ndev);
>  >+
> If user never open the interface, ethtool_stats[] always is 0 that are not expected.
> So, it also should be called at . fec_enet_init() ?

I don't think that zero stats is wrong for never-opened interface.

However a call at init path won't hurt, so I'll add it, just to clear
the question.

Nikita
