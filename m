From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Tue, 07 Oct 2014 07:34:44 -0700
Message-ID: <1412692484.11091.123.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
	 <063D6719AE5E284EB5DD2968C1650D6D174C6025@AcuExch.aculab.com>
	 <20141007161702.7cd1e800@ipc1.ka-ro>
	 <063D6719AE5E284EB5DD2968C1650D6D174C60B1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Lothar =?ISO-8859-1?Q?Wa=DFmann=27?= <LW@KARO-electronics.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C60B1@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-10-07 at 14:23 +0000, David Laight wrote:

> The point I was making is that if you have to do a read-write of the received
> data (to byteswap it) then you might as well always copy it into a new skb that
> is just big enough for the actual receive frame.

+1
