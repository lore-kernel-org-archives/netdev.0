From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Wed, 12 Dec 2007 15:13:13 -0800
Message-ID: <20071212151313.6b668290@freepuppy.rosehill>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>
	<474C2246.50205@ee.ethz.ch>
	<20071129134554.5c25a891@freepuppy.rosehill>
	<474F3719.30101@trash.net>
	<47503971.9080509@ee.ethz.ch>
	<4753B423.7030000@trash.net>
	<4753C874.80703@ee.ethz.ch>
	<47543E65.4060303@trash.net>
	<47544B1F.1010902@candelatech.com>
	<20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch>
	<47556B20.2030700@trash.net>
	<4756A046.1070608@ee.ethz.ch>
	<4756A213.2060806@trash.net>
	<475D4DEE.2080308@ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57317 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751081AbXLLXPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 18:15:10 -0500
In-Reply-To: <475D4DEE.2080308@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Dec 2007 15:32:14 +0100
Ariane Keller <ariane.keller@tik.ee.ethz.ch> wrote:

> I finally managed to rewrite the netem trace extension to use rtnetlink 
> communication for the data transfer for user space to kernel space.
> 
> The kernel patch is available here:
> http://www.tcn.hypert.net/tcn_kernel_2_6_23_rtnetlink
> 
> and the iproute patch is here:
> http://www.tcn.hypert.net/tcn_iproute2_2_6_23_rtnetlink
> 
> Whenever new data is needed the kernel module sends a notification to 
> the user space process. Thereupon the user space process sends a data 
> package to the kernel module.

I wonder if it wouldn't be possible to enhance/extend netlink
to use sendfile/splice to get the data.  It is rather more work than
needed for just this, but it would be useful for large configuration.

> I had to write a new qdisc_notify function (qdisc_notify_pid) since the 
> other was acquiring a lock, which we already hold in this situation.



> I hope everything works as expected and I'm looking forward for your 
> comments.
> 
> Thanks!
> Ariane


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
