From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Thu, 06 Sep 2007 16:30:30 +0100
Message-ID: <46E01D16.5000609@katalix.com>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com> <20070906153700.57a0c448@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, davem@davemloft.net,
	jeff@garzik.org, mandeep.baines@gmail.com, ossthema@de.ibm.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:43132 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755421AbXIFPae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 11:30:34 -0400
In-Reply-To: <20070906153700.57a0c448@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> What about the latency that NAPI imposes? Right now there are certain applications that
> don't like NAPI because it add several more microseconds, and this may make it worse.

Latency is something that I think this approach will actually improve, 
at the expense of additional polling. Or is it the ksoftirqd scheduling 
latency that you are referring to?

> Maybe a per-device flag or tuning parameters (like weight sysfs value)? or some other
> way to set low-latency values.

Yes. I'd like to think good defaults could be derived though, perhaps 
based on settings like CONFIG_PREEMPT, CONFIG_HIGH_RES_TIMER, CONFIG_HZ 
and maybe even bogomips / nr_cpus.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

