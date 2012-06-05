From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH net-next 5/5] gianfar_ethtool: coding style and whitespace
 cleanups
Date: Tue, 05 Jun 2012 07:54:29 +0200
Message-ID: <4FCD9F15.2050605@computer.org>
References: <1338827516-18425-6-git-send-email-jan.ceuleers@computer.org> <20120604.140850.1847853625568125563.davem@davemloft.net> <4FCD084D.6020408@computer.org> <20120604.155229.822064530175335346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: b06378@freescale.com, joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:31251 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752602Ab2FEFy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 01:54:56 -0400
In-Reply-To: <20120604.155229.822064530175335346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2012 09:52 PM, David Miller wrote:
> From: Jan Ceuleers <jan.ceuleers@computer.org>
> Date: Mon, 04 Jun 2012 21:11:09 +0200
> 
>> Well then I'm sorry but I won't be resubmitting
> 
> Because you can't test the build?
> 
> You absolutely can, on any architecture, that's how I found your typo.
> 
> Force the build with "make path/to/driver/foo.o" and scan through the
> non-architecture-specific warnings and errors.

I don't want to waste your time, and I'm sorry for having made a typo,
and I thank you for finding it, but I had tried that and hit the
following (I'm on x86):

  CC      drivers/net/ethernet/freescale/gianfar.o
drivers/net/ethernet/freescale/gianfar.c:91:21: fatal error: asm/reg.h:
No such file or directory
compilation terminated.
make[1]: *** [drivers/net/ethernet/freescale/gianfar.o] Error 1
make: *** [drivers/net/ethernet/freescale/gianfar.o] Error 2

That's without any of my patches applied.

The missing file exists only on some architectures:

janc@mordor:~/git/net-next$ find arch -name reg.h -print
arch/powerpc/boot/reg.h
arch/powerpc/include/asm/reg.h
arch/alpha/include/asm/reg.h
arch/mips/include/asm/reg.h
arch/arm/mach-bcmring/include/csp/reg.h

So your build environment happens to be one of powerpc, alpha or mips,
does it?

I will submit a v2 as RFC. Would the Freescale team please look at it?

Thanks, Jan
