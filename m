From: "Jesse Huang" <jesse@icplus.com.tw>
Subject: Re: [PATCH] IP1000A: IC Plus update 2006-08-22
Date: Thu, 31 Aug 2006 16:38:54 +0800
Message-ID: <00a101c6ccd8$e4c425a0$4964a8c0@icplus.com.tw>
References: <1156268234.3622.1.camel@localhost.localdomain> <20060822232730.GA30977@electric-eye.fr.zoreil.com> <20060823113822.GA17103@electric-eye.fr.zoreil.com> <20060823223032.GA25111@electric-eye.fr.zoreil.com> <026c01c6c71d$0fde1730$4964a8c0@icplus.com.tw> <20060824220758.GA19637@electric-eye.fr.zoreil.com> <20060827220816.GA21788@electric-eye.fr.zoreil.com> <002a01c6ca43$ae73ebd0$4964a8c0@icplus.com.tw> <20060830224340.GA6248@electric-eye.fr.zoreil.com>
Cc: <penberg@cs.Helsinki.FI>, <akpm@osdl.org>, <dvrabel@cantab.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<david@pleyades.net>, <dominik.schulz@gauner.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr42.hinet.net ([168.95.4.142]:21231 "EHLO msr42.hinet.net")
	by vger.kernel.org with ESMTP id S1751402AbWHaIj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 04:39:28 -0400
To: "Francois Romieu" <romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois:

In 0049-ip1000-switch-to-classical-tx_current-tx_dirty-ring-management.txt:

> The LastFreedTxBuff/LastTFDHoldAddr/LastTFDHoldCnt stuff in the xmit
> handler took care of the skb submitted by the upper layer when the
> ring was full, i.e. too late: the xmit handler now disables queueing
> (i.e. netif_stop_queue) when the whole Tx ring is completely full.
> The Tx irq handler does the required work to enable queuing again
> when some room is made. The remainder of the LastTFDHoldFoo (see
> ipg_nic_hard_start_xmit and ipg_nic_txfree) is moved to a tx_timeout
> handler where it imho belongs.

It is better to Use tx_timeout than the original one.
Thanks for that.

Best Regards,
Jesse Huang

----- Original Message ----- 
From: "Francois Romieu" <romieu@fr.zoreil.com>
To: "Jesse Huang" <jesse@icplus.com.tw>
Cc: <penberg@cs.Helsinki.FI>; <akpm@osdl.org>; <dvrabel@cantab.net>;
<linux-kernel@vger.kernel.org>; <netdev@vger.kernel.org>;
<david@pleyades.net>; <dominik.schulz@gauner.org>
Sent: Thursday, August 31, 2006 6:43 AM
Subject: Re: [PATCH] IP1000A: IC Plus update 2006-08-22


Francois Romieu <romieu@fr.zoreil.com> :
[...]
> Added:
>
0043-ip1000-use-the-new-IRQF_-constants-and-the-dma_-alloc-free-_coherent-AP
> I.txt
> 0044-ip1000-mixed-case-and-upper-case-removal.txt
> 0045-ip1000-add-ipg_-r-w-8-16-32-macros.txt

Added:
0046-ip1000-kiss-TxBuffDMAhandle-goodbye.txt
0047-ip1000-kiss-RxBuffDMAhandle-goodbye.txt
0048-ip1000-turn-StationAddr-0-1-2-into-an-array.txt
0049-ip1000-switch-to-classical-tx_current-tx_dirty-ring-management.txt

The previous branch for the driver at
git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git has been stored
as 'netdev-ipg-20060831.old'. The current one is based on dc709bd and
named 'ipg'.

Nothing will be pushed tomorrow as I have some bugs to review in different
drivers.

-- 
Ueimor


