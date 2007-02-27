From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ehea: NAPI multi queue TX/RX path for SMP
Date: Tue, 27 Feb 2007 07:42:13 +0100
Message-ID: <1172558533.11949.38.camel@localhost.localdomain>
References: <200702261700.51220.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Roland Dreier <rdreier@cisco.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52697 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932889AbXB0Gma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 01:42:30 -0500
In-Reply-To: <200702261700.51220.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-02-26 at 17:00 +0100, Jan-Bernd Themann wrote:
> Hi!
> 
> This patch replaces the former posted patch
> ([PATCH] ehea: Optional TX/RX path optimized for SMP) and provides
> a functionality that allows parallel RX processing on multiple RX
> queues by using dummy netdevices as proposed by Roland Dreier.
> The fairness amongst this net devices and other network devices 
> is thus better than in our first approach.
> 
> Is there a way to avoid overloading a single CPU with multiple netdev
> receive processes using NAPI? A distribution based on CPU load might
> help to improve the throughput. Pinning interrupts shows there is 
> still some room for improvements.

You may also want to look at the patches proposed by Dave Miller for
splitting NAPI from netdevice so you can actually instanciate multiple
NAPI "pollers"

Ben.


