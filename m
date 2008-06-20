From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: data received but not detected
Date: Fri, 20 Jun 2008 22:23:34 +0400
Message-ID: <20080620182333.GA9342@2ka.mipt.ru>
References: <48583B37.5070708@candelatech.com> <1213743506.5771.220.camel@localhost.localdomain> <20080618062857.GA3598@2ka.mipt.ru> <1213917029.9245.86.camel@localhost.localdomain> <20080620060219.GA22784@2ka.mipt.ru> <1213981859.9245.133.camel@localhost.localdomain> <20080620172513.GA16673@2ka.mipt.ru> <1213983664.9245.150.camel@localhost.localdomain> <20080620175440.GA12197@2ka.mipt.ru> <1213985826.9245.169.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Travis Stratman <tstratman@emacinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41423 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956AbYFTSXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 14:23:52 -0400
Content-Disposition: inline
In-Reply-To: <1213985826.9245.169.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2008 at 01:17:06PM -0500, Travis Stratman (tstratman@emacinc.com) wrote:
> Let me clarify this again... I see the packet being sent at the expected
> time from the sender on the tcpdump. The packet does not show up in
> tcpdump or in the application on the receive side. When some other data
> is received by the receiver (i.e. ARP), the missing packet shows up in
> the tcpdump and in the application at the same time. So the delay shows
> up in the tcpdump as well. It seems to me that everything is pointing to
> the packet being in the DMA buffer but the controller driver not knowing
> anything about it.

Argh. Ok, then please check that napi polling is called and rx interrupt
happen for the driver.

-- 
	Evgeniy Polyakov
