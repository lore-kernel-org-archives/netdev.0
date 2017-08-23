From: Stefan Chulski <stefanc@marvell.com>
Subject: RE: [EXT] Re: [PATCH net-next 10/18] net: mvpp2: use the GoP
 interrupt for link status changes
Date: Wed, 23 Aug 2017 15:24:55 +0000
Message-ID: <5ebd192c54984b25adda0a294035b1b9@IL-EXCH01.marvell.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-11-antoine.tenart@free-electrons.com>
 <20170726162648.GK12049@lunn.ch> <20170823082510.GD5202@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "thomas.petazzoni@free-electrons.com"
 <thomas.petazzoni@free-electrons.com>,
 "jason@lakedaemon.net" <jason@lakedaemon.net>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
 Nadav Haklai <nadavh@marvell.com>,
 "gregory.clement@free-electrons.com" <gregory.clement@free-electrons.com>,
 "mw@semihalf.com" <mw@semihalf.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>
To: Antoine Tenart <antoine.tenart@free-electrons.com>, Andrew Lunn
 <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170823082510.GD5202@kwain>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> When the cable is connected (there is signal) and the serdes is in sync and AN
> succeeded.
> 
> > With SFF/SFP ports, you generally need a gpio line the fibre module
> > can use to indicate if it has link. Fixed-phy has such support, and
> > your link_change function will get called when the link changes.
> 
> So that would work when using SFP modules but I wonder if the GoP irq isn't
> needed when using passive cable, in which case this patch would still be needed
> (and of course we should support the new Russell phylib capabilities).
> 
> What's your thoughts on this?
> 
> Thanks!
> Antoine
> 

Even if new phylib driver supports passive direct cables connection, 
GoP IRQ required for SOHO/Peridot external switch support.
SOHO/Peridot external switch could be connected directly to Serdes line.

Regards,
Stefan
