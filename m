From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Thu, 22 May 2008 18:32:07 +0200
Message-ID: <4835A007.7020601@krogh.cc>
References: <4824CBA1.8040703@sun.com>	<4824CCF0.5050302@krogh.cc>	<4824D1E1.10007@sun.com> <20080509.154538.28321777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matheos.Worku@Sun.COM, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:55366 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753846AbYEVQcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 12:32:19 -0400
In-Reply-To: <20080509.154538.28321777.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Matheos Worku <Matheos.Worku@Sun.COM>
> Date: Fri, 09 May 2008 15:36:17 -0700
> 
>> I have observed TX throughput degradation (and increased CPU 
>> utilization)  occurs with increased # of connections, when CPU count > 4 
>> CPUs.  I don't think it is related to the driver (or HW).
> 
> All transmits through a device are fully serialized currently,
> it's a known problem and something we plan to fix.

I google'd up this one:

http://vger.kernel.org/~davem/davem_tokyo08.pdf (slide 23+).

Does this mean that I can expect every 10G card to have this limitation
under Linux? Or are some known to be better than others?
(I can probably justify paying for another 10G card if I can expect to
gain the last 400MB/s).

Since I cannot push more than ~600MB/s through the NIC before a single 
cpu is bottlenecked, it seem most likely to be this TX throughput
thing I hit.

Thanks

Jesper
-- 
Jesper
