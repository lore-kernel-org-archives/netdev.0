From: Christian Riesch <christian@riesch.at>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 23:34:06 +0200
Message-ID: <4C9BC7CE.8020400@riesch.at>
References: <cover.1285261533.git.richard.cochran@omicron.at>	<alpine.DEB.2.00.1009231238170.2962@router.home>	<1285268380.2587.11.camel@localhost.localdomain>	<alpine.DEB.2.00.1009231402420.2962@router.home>	<1285273684.2587.92.camel@localhost.localdomain>	<alpine.DEB.2.00.1009231533040.7522@router.home> <20100923223417.4ed62e5b@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>,
	john stultz <johnstul@us.ibm.com>,
	Richard Cochran <richardcochran@gmail.com>,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-api@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay01.ispgateway.de ([80.67.31.39]:36636 "EHLO
	smtprelay01.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665Ab0IWVeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:34:14 -0400
In-Reply-To: <20100923223417.4ed62e5b@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox wrote:
>> It implies clock tuning in userspace for a potential sub microsecond
>> accurate clock. The clock accuracy will be limited by user space
>> latencies and noise. You wont be able to discipline the system clock
>> accurately.
> 
> Noise matters, latency doesn't. 

Well put! That's why we need hardware support for PTP timestamping to 
reduce the noise, but get along well with the clock servo that is 
steering the PHC in user space.

Christian
