From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 27 Aug 2010 13:41:54 +0100
Message-ID: <20100827134154.50eef56c@lxorguk.ukuu.org.uk>
References: <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	<AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
	<20100817085324.GB3330@riccoc20.at.omicron.at>
	<1282090963.1734.97.camel@localhost>
	<20100818071942.GA4096@riccoc20.at.omicron.at>
	<1282176776.2865.100.camel@localhost.localdomain>
	<20100819055518.GA4084@riccoc20.at.omicron.at>
	<1282594125.3111.344.camel@localhost.localdomain>
	<AANLkTi=nKrRHH6+9mvny718gov8Q+u7DHFikdgNY8YdX@mail.gmail.com>
	<1282874269.4371.74.camel@localhost.localdomain>
	<20100827075727.GA3818@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti@linux.it>, Arnd Bergmann <arnd@arndb.de>,
	john stultz <johnstul@us.ibm.com>, devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	Christian Riesch <christian.riesch@omicron.at>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100827075727.GA3818@riccoc20.at.omicron.at>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> The master node in a PTP network probably takes its time from a
> precise external time source, like GPS. The GPS provides a 1 PPS
> directly to the PTP clock hardware, which latches the PTP hardware
> clock time on the PPS edge. This provides one sample as input to a
> clock servo (in the PTPd) that, in turn, regulates the PTP clock
> hardware.

A PTP clock is TAI, Unix time is UTC.

> This is the core issue and source of misunderstanding, in my view. The
> fact of the matter is, the current generation of computers has
> multiple clocks, and these are usually unsynchronized. I think we
> should not try too hard to cover up or work around this. It is a fact
> of life.

In this case I don't think you can. Their divergence is rather difficult
to handle unless you have a GPS to hand.

But all this talk of "PTP this" and "PTP that" is not helpful. Any
interface for additional time sources should be generic with PTP being
one use case.

Alan
