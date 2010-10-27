From: "Tomoya MORINAGA" <tomoya-linux@dsn.okisemi.com>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix buildwarnings
Date: Wed, 27 Oct 2010 20:27:29 +0900
Message-ID: <008201cb75c9$f27ff720$66f8800a@maildom.okisemi.com>
References: <4CC61B1B.3090602@dsn.okisemi.com>	<20101026.105206.15244527.davem@davemloft.net>	<20101026.105545.200376685.davem@davemloft.net><4CC71DA4.3020600@grandegger.com> <4CC72360.1070608@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <andrew.chih.howe.khor@intel.com>,
	<socketcan-core@lists.berlios.de>, <sameo@linux.intel.com>,
	<margie.foster@intel.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <yong.y.wang@intel.com>,
	<masa-korg@dsn.okisemi.com>, <kok.howg.ewe@intel.com>,
	<chripell@fsfe.org>, <morinaga526@dsn.okisemi.com>,
	"David Miller" <davem@davemloft.net>, <joel.clark@intel.com>,
	<qi.wang@intel.com>
To: "Marc Kleine-Budde" <mkl@pengutronix.de>,
	"Wolfgang Grandegger" <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, October 27, 2010 3:52 AM :  Marc Kleine-Budde and Wolfgang Grandegge wrote:

The following is some inarticulate points I have for your questions.
Please give me more information.

> Do I understand your code correctly? You have a big loop, but only do
>  two different things at certain values of the loop? Smells fishy.
Uh, I can't understand your intention.
Please show in detail.
This processing does configuration for all message objects.


> what does this loop do? why is it nessecarry? I don't like delay loops
>   in the hot path of a driver.
This loop is for waiting for all tx Message Object completion.
This is Topcliff CAN HW specification.


> If you figured out how to use the endianess conversion functions from
> the cpu_to_{le,be}-{le,to}_to_cpup family use them here, too.
Uh,le32_to_cpu have been used already here.
I can't understand your intention.
Please show in detail.


>> All these check if busy in the code make me a bit nervous, can you
>> please explain why they are needed. A pointer to the manual is okay, too.
> Me too. I already ask in my previous mail how long that functions
> usually blocks.
When accessing read/write from/to Message RAM,
Since it takes much time for transferring between Register and Message RAM,
SW must check busy flag of CAN register.
This is a Topcliff HW specification.


> is there some pdev->name instead of KBUILD_MODNAME that can be used?
I can't understand your intention.
pdev(struct pci_dev) doesn't have "name" member. 
Please show in detail.

Thanks, Tomoya(OKI SEMICONDUCTOR CO., LTD.)
