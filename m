From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA vs envelope frames
Date: Wed, 30 Nov 2016 16:10:28 +0100
Message-ID: <20161130151028.GD21645@lunn.ch>
References: <1480444528-30054-1-git-send-email-nikita.yoush@cogentembedded.com>
 <AM4PR0401MB2260D022EC9B9E4C4333E621FF8C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <dab27a3d-821c-8d07-ad98-2bdd8c442bc5@cogentembedded.com>
 <f632a0e8-746b-2db5-09af-3a5f6fc78e13@lab.ntt.co.jp>
 <d8a6df03-d9bd-eca5-0b9f-73406efe6509@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
        Andy Duan <fugang.duan@nxp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        florian Fainelli <f.fainelli@gmail.com>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d8a6df03-d9bd-eca5-0b9f-73406efe6509@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> What is not really clear - what if several tagging protocols are used
> together. AFAIU, things may be more complex that simple appending of
> tags, e.g. EDSA tag can carry VLAN id inside.

Hi Nikita

At least for all current tagging protocols, the size of the tag is
constant. And you cannot run different tagging protocols on the same
master interface at the same time.

However, i think Florian tried something funky with the SF2 and B53
driver. He has a b53 hanging off a sf2. So i think he used nested
tagging protocols!

	Andrew
