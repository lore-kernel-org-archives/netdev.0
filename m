From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Mon, 3 Oct 2011 14:56:08 +0000
Message-ID: <953B660C027164448AE903364AC447D2235DAA9D@MTLDAG02.mtl.com>
References: <1317388995-411-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <953B660C027164448AE903364AC447D2235D9A8C@MTLDAG02.mtl.com>
 <20111003143721.GA3596@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Cohen <eli@mellanox.co.il>,
	"eli@dev.mellanox.co.il" <eli@dev.mellanox.co.il>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:54115 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756260Ab1JCO4N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 10:56:13 -0400
In-Reply-To: <20111003143721.GA3596@oc1711230544.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hello, Yevgeny.
> 
> We use a MT26448 (lspci -v output bellow) on a POWER7. Any other
> information, tests or debug patches you want me to try, just tell me.
> 
> I expected this was really not the proper fix, but thought it would be
> better to send it than just guess. Any clues what the problem might be?
> Perhaps, we would have to disable blue frame for this particular device?
> 
> Regards,
> Cascardo.
> 
> ---
> lspci output
> 0006:01:00.0 Ethernet controller: Mellanox Technologies MT26448 [ConnectX EN 10GigE, PCIe 2.0 5GT/s] (rev b0)
> ---
> lspci -v output
> 0006:01:00.0 0200: 15b3:6750 (rev b0)
>         Subsystem: 1014:0416
>         Flags: bus master, fast devsel, latency 0, IRQ 31
>         Memory at 3da47be00000 (64-bit, non-prefetchable) [size=1M]
>         Memory at 3da47c000000 (64-bit, prefetchable) [size=32M]
>         Expansion ROM at 3da47bf00000 [disabled] [size=1M]
>         Capabilities: [40] Power Management version 3
>         Capabilities: [48] Vital Product Data
>         Capabilities: [9c] MSI-X: Enable+ Count=128 Masked-
>         Capabilities: [60] Express Endpoint, MSI 00
>         Capabilities: [100] Alternative Routing-ID Interpretation (ARI)
>         Capabilities: [148] Device Serial Number 00-02-c9-03-00-0f-50-be
>         Kernel driver in use: mlx4_core
>         Kernel modules: mlx4_en, mlx4_core
> ---

Cascardo,

Can you also send me the output of ethtool -i?
It seems that there is a problem with write combining on Power processors, we will check this issue.

Yevgeny
