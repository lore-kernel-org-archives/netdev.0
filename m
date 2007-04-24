From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: PROBLEM: sky2 hangs
Date: Tue, 24 Apr 2007 08:15:57 -0700
Message-ID: <20070424081557.1b8f6b31@oldman>
References: <20070403151908.41E574AC7F@dcn.infos.ru>
	<20070424082451.25E3C4AC19@dcn.infos.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Peter Trifonov" <petert@dcn.infos.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52531 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422721AbXDXPQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 11:16:07 -0400
In-Reply-To: <20070424082451.25E3C4AC19@dcn.infos.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Apr 2007 12:24:51 +0400
"Peter Trifonov" <petert@dcn.infos.ru> wrote:

> Dear Stephen,
> 
> Unfortunately the problems with sky2 started again. 
> 
> From time to time NIC stops working. The system log contains the following
> messages:
> Apr 24 11:50:43 bullet-lin kernel: sky2 eth0: Link is up at 1000 Mbps, full
> duplex, flow control both
> Apr 24 11:51:55 bullet-lin kernel: sky2 0000:04:00.0: pci hw error (0x2010)
> Apr 24 11:53:32 bullet-lin kernel: sky2 eth0: disabling interface
> Apr 24 11:53:35 bullet-lin kernel: sky2 eth0: enabling interface
> Apr 24 11:53:35 bullet-lin kernel: sky2 eth0: ram buffer 0K
> Apr 24 11:53:37 bullet-lin kernel: sky2 eth0: Link is up at 1000 Mbps, full
> duplex, flow control both
> Apr 24 12:06:32 bullet-lin kernel: sky2 eth0: tx timeout
> Apr 24 12:06:32 bullet-lin kernel: sky2 eth0: transmit ring 1 .. 472
> report=1 done=1
> Apr 24 12:06:32 bullet-lin kernel: sky2 hardware hung? flushing
> Apr 24 12:06:32 bullet-lin kernel: sky2 eth0: transmit descriptor error
> (hardware problem)
> Apr 24 12:06:32 bullet-lin kernel: sky2 eth0: Link is down.
> Apr 24 12:06:38 bullet-lin kernel: sky2 eth0: Link is up at 1000 Mbps, full
> duplex, flow control both
> Apr 24 12:06:38 bullet-lin kernel: sky2 eth0: transmit descriptor error
> (hardware problem)
> Apr 24 12:06:38 bullet-lin kernel: sky2 eth0: Link is down.
> Apr 24 12:06:41 bullet-lin kernel: sky2 eth0: Link is up at 1000 Mbps, full
> duplex, flow control both
> Apr 24 12:06:41 bullet-lin kernel: sky2 eth0: transmit descriptor error
> (hardware problem)
> .....
> 
> I am running 2.6.20.4 X86-64 kernel
> 
> With best regards,
> P. Trifonov  

I bet you have 88e8056 chip.  There is some problem with the bus interface
and the sky2 driver (and the vendor sk98lin driver), that causes all sorts
of out of order device access problems.  Still investigating....

For 2.6.21, I ended up blacklisting this version of the chip until the problem
is resolved.
