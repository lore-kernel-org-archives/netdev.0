From: Christian Riesch <christian@riesch.at>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Sun, 29 Aug 2010 15:32:20 +0200
Message-ID: <4C7A6164.60208@riesch.at>
References: <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>	<AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>	<20100817085324.GB3330@riccoc20.at.omicron.at>	<1282090963.1734.97.camel@localhost>	<20100818071942.GA4096@riccoc20.at.omicron.at>	<1282176776.2865.100.camel@localhost.localdomain>	<20100819055518.GA4084@riccoc20.at.omicron.at>	<1282594125.3111.344.camel@localhost.localdomain>	<AANLkTi=nKrRHH6+9mvny718gov8Q+u7DHFikdgNY8YdX@mail.gmail.com>	<1282874269.4371.74.camel@localhost.localdomain>	<20100827075727.GA3818@riccoc20.at.omicron.at>
	<20100827134154.50eef56c@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti@linux.it>, Arnd Bergmann <arnd@arndb.de>,
	john stultz <johnstul@us.ibm.com>,
	Richard Cochran <richardcochran@gmail.com>, linux-kernel@vger.kernel.org,
	Christian Riesch <christian.riesch@omicron.at>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	devicetree-discuss@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100827134154.50eef56c@lxorguk.ukuu.org.uk>
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

Alan Cox wrote:
>> The master node in a PTP network probably takes its time from a
>> precise external time source, like GPS. The GPS provides a 1 PPS
>> directly to the PTP clock hardware, which latches the PTP hardware
>> clock time on the PPS edge. This provides one sample as input to a
>> clock servo (in the PTPd) that, in turn, regulates the PTP clock
>> hardware.
> 
> A PTP clock is TAI, Unix time is UTC.

Not necessarily. AFAIK, the time distributed by IEEE1588v2 can either be 
based on the "PTP epoch" (timePropertiesDS.ptpTimescale=TRUE) and thus 
represent TAI or be based on an implementation specific arbitrary epoch 
(timePropertiesDS.ptpTimescale=FALSE) and represent time on some 
arbitrary time scale.

Christian
