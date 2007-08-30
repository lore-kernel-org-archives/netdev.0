From: Satyam Sharma <satyam@infradead.org>
Subject: Re: Bug? Realtek RTL-8169 Gigabit Ethernet  and High Resolution
 Timers
Date: Thu, 30 Aug 2007 22:21:41 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708302218590.28360@enigma.security.iitk.ac.in>
References: <002d01c7eb14$4b18fab0$0100a8c0@hak>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	romieu@fr.zoreil.com, netdev@vger.kernel.org, tglx@linutronix.de
To: n <xellos@bluebottle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:39126 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757030AbXH3Qik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 12:38:40 -0400
In-Reply-To: <002d01c7eb14$4b18fab0$0100a8c0@hak>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Adding relevant Cc:'s ]


On Thu, 30 Aug 2007, n wrote:

> I found a bug when using the Ethernet controller: Realtek Semiconductor Co.,
> Ltd. RTL-8169 Gigabit Ethernet (rev 10)  ethernet card and kernel High
> Resolution Timers (menuconfig -> Processor type and features -> High
> Resolution Timer Support )
> after about 20 kernel compiles i finnaly figured out this option was making
> the ethernet card slow
> tested kernels 2.6.22,2.6.22.5, 2.6.23-rc4 (running now)
> 
> the cpu is the pc is a p3 667 mhz so its cpu limited i guess and maxes at
> 400mbit~. (without High Resolution Timers )
> with High Resolution Timers off it would only do 50-70mbit.
> 
> r8169 (compile as module + napi)
> High Resolution Timer Support (enabled)
> tested with iperf also system is very unresponsive i cant even open a ssh
> session or type a command while the test ran
> [  5]  0.0-10.0 sec  64.5 MBytes  54.0 Mbits/sec
> 
> r8169 (compile as module + napi)
> High Resolution Timer Support (disabled)
> [  3]  0.0-10.0 sec    552 MBytes    463 Mbits/sec
> 
> as you can see with it disabled the speed really improved.
> but im wondering what does High Resolution Timer's do and what does it have to
> do with a pci gigabit ethernet card that would slow it down
> maybe someone else could test and see if they get the same results
> 
> this might solve alot of problems with this card since alot of distros compile
> Resolution Timer default to enabled...
