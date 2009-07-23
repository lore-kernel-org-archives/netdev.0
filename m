From: Jeff Haran <jharan@Brocade.COM>
Subject: Claimed reduction in ARP table size when ARPD is configured
Date: Thu, 23 Jul 2009 14:23:26 -0700
Message-ID: <7FEA3773D8EA0A42B611AB23563EA2F2E9A69D03@HQ-EXCH-7.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:34118 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558AbZGWV2i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 17:28:38 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johathan Layes,

Your name shows up in the list of maintainers for ARPD, so I am asking you my question. If this is inappropriate, my apologies, please let me know who I could forward the question to.

net/ipv4/Kconfig contains the following text about config ARPD:

"If you say Y here, the kernel's internal ARP cache will never grow to more than 256 entries"

Yet, try as I might, I cannot see where in the kernel sources any #ifdef CONFIG_ARPD'ed code would actually change the maximum size of the kernel resident ARP cache.

Is this statement about the maximum internal ARP cache size when ARPD is configured no longer accurate or am I missing something?

If kernel code did at one time reduce the maximum internal ARP cache size, what is the latest version in which it did?

BTW, I know ARPD is described as obsolete, but we have a use for the notifications it provides that has nothing to do with user space ARP daemons and if it goes away in the future we will deal with it then.

Please response to my email directly, as I do not subscribe to netdev.

Thanks,

Jeffrey Haran
Brocade Communications
