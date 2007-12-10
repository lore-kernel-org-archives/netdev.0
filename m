From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Mon, 10 Dec 2007 15:32:14 +0100
Message-ID: <475D4DEE.2080308@ee.ethz.ch>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch> <47556B20.2030700@trash.net> <4756A046.1070608@ee.ethz.ch> <4756A213.2060806@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:45370 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756586AbXLJOcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 09:32:20 -0500
In-Reply-To: <4756A213.2060806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I finally managed to rewrite the netem trace extension to use rtnetlink 
communication for the data transfer for user space to kernel space.

The kernel patch is available here:
http://www.tcn.hypert.net/tcn_kernel_2_6_23_rtnetlink

and the iproute patch is here:
http://www.tcn.hypert.net/tcn_iproute2_2_6_23_rtnetlink

Whenever new data is needed the kernel module sends a notification to 
the user space process. Thereupon the user space process sends a data 
package to the kernel module.
I had to write a new qdisc_notify function (qdisc_notify_pid) since the 
other was acquiring a lock, which we already hold in this situation.

I hope everything works as expected and I'm looking forward for your 
comments.

Thanks!
Ariane
