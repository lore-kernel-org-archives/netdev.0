From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: r8169: Thecus N2100, multicast packets problem
Date: Sun, 20 Jul 2008 23:24:55 +0300
Message-ID: <20080720202455.GA5036@deprecation.cyrius.com>
References: <87lk0cpej3.fsf@frontier.dottedmag.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mikhail Gusarov <dottedmag@dottedmag.net>, netdev@vger.kernel.org,
	407217@bugs.debian.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:4460 "EHLO sorrow.cyrius.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751540AbYGTU0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jul 2008 16:26:42 -0400
Content-Disposition: inline
In-Reply-To: <87lk0cpej3.fsf@frontier.dottedmag.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois,

Did you see the bug report below?  Several people are affected by this
(all on the same hardware) and apparently this has never worked (i.e.
also shows up with 2.6.18).

* Mikhail Gusarov <dottedmag@dottedmag.net> [2008-07-08 22:43]:
> Hello,
> 
> I'm experiencing a problem with RTL-8169 network card on Thecus N2100
> NAS device on 2.6.24 and 2.6.25 kernels (did not try other versions).
> 
> System seems to be unable either to receive or to transmit multicast
> packets until promiscous mode is set on interface: mDNS does not work on
> this device, both for resolving other .local names or answering mDNS
> requests.
> 
> Running tcpdump corrects the situation. Unicast packets work fine.
> 
> I'm not on the list, so please keep me in CC.
> 
> Additional info:
> 
> [dottedmag@homenas:~]1% cat /proc/cpuinfo 
> Processor	: XScale-80219 rev 0 (v5l)
> BogoMIPS	: 593.10
> Features	: swp half fastmult edsp 
> CPU implementer	: 0x69
> CPU architecture: 5TE
> CPU variant	: 0x0
> CPU part	: 0x2e3
> CPU revision	: 0
> Cache type	: undefined 5
> Cache clean	: undefined 5
> Cache lockdown	: undefined 5
> Cache format	: Harvard
> I size		: 32768
> I assoc		: 32
> I line length	: 32
> I sets		: 32
> D size		: 32768
> D assoc		: 32
> D line length	: 32
> D sets		: 32
> 
> Hardware	: Thecus N2100
> Revision	: 0000
> Serial		: 0000000000000000
> [dottedmag@homenas:~]% lspci
> 00:01.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
> 00:02.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
> 00:03.0 Mass storage controller: Silicon Image, Inc. SiI 3512 [SATALink/SATARaid] Serial ATA Controller (rev 01)
> 00:04.0 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 62)
> 00:04.1 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 62)
> 00:04.2 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 65)
> [dottedmag@homenas:~]% lspci -n
> 00:01.0 0200: 10ec:8169 (rev 10)
> 00:02.0 0200: 10ec:8169 (rev 10)
> 00:03.0 0180: 1095:3512 (rev 01)
> 00:04.0 0c03: 1106:3038 (rev 62)
> 00:04.1 0c03: 1106:3038 (rev 62)
> 00:04.2 0c03: 1106:3104 (rev 65)
> [dottedmag@homenas:~]% uname -a
> Linux homenas 2.6.25-2-iop32x #2 Sat Jun 28 16:10:57 UTC 2008 armv5tel GNU/Linux
> 
> -- 



-- 
Martin Michlmayr
http://www.cyrius.com/
