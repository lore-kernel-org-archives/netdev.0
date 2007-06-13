From: Benjamin LaHaise <bcrl@kvack.org>
Subject: r8169 tx problem (1s pause with ping)
Date: Tue, 12 Jun 2007 20:41:54 -0400
Message-ID: <20070613004154.GA4187@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:53328 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbXFMAmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 20:42:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello folks,

I'm seeing something odd with r8169 on FC7: doing a ping -s 1600 alternates 
between a 1s latency and sub 1ms.  Has anyone else seen anything like this?  
The system in question is an Asus M2A-VM with an onboard RTL8111 (I think).  
NAPI doesn't seem to make a difference.  The kernel in question is currently 
a vanilla 2.6.21.5.  Sub-mtu sized packets behave normally.

02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 01)

PING 1.2.3.4 (1.2.3.4) 1600(1628) bytes of data.
1608 bytes from 1.2.3.4: icmp_seq=1 ttl=64 time=1000 ms
1608 bytes from 1.2.3.4: icmp_seq=2 ttl=64 time=0.816 ms
1608 bytes from 1.2.3.4: icmp_seq=3 ttl=64 time=1000 ms
1608 bytes from 1.2.3.4: icmp_seq=4 ttl=64 time=0.661 ms

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
