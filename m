From: Christoph Lameter <cl@linux-foundation.org>
Subject: [IB] 2.6.31-rc9: SW2HW_EQ failed on Dell R610
Date: Tue, 8 Sep 2009 18:06:54 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909081805110.7733@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:46445 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751922AbZIHWHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 18:07:54 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A7EAF82C2BB
	for <netdev@vger.kernel.org>; Tue,  8 Sep 2009 18:08:47 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ugZo1DtBWD6w for <netdev@vger.kernel.org>;
	Tue,  8 Sep 2009 18:08:43 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0EC7982C2B4
	for <netdev@vger.kernel.org>; Tue,  8 Sep 2009 18:08:40 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem with the interrupts is not solved in rc9:

[    7.747804] mlx4_core: Mellanox ConnectX core driver v0.01 (May 1,
2007)
[    7.747806] mlx4_core: Initializing 0000:04:00.0
[    7.747839] mlx4_core 0000:04:00.0: PCI INT A -> GSI 38 (level, low) ->
IRQ 38
[    7.747850] mlx4_core 0000:04:00.0: setting latency timer to 64
[    9.759505] mlx4_core 0000:04:00.0: irq 62 for MSI/MSI-X
[    9.759513] mlx4_core 0000:04:00.0: irq 63 for MSI/MSI-X
[    9.759520] mlx4_core 0000:04:00.0: irq 64 for MSI/MSI-X
[    9.759527] mlx4_core 0000:04:00.0: irq 65 for MSI/MSI-X
[    9.759533] mlx4_core 0000:04:00.0: irq 66 for MSI/MSI-X
[    9.759540] mlx4_core 0000:04:00.0: irq 67 for MSI/MSI-X
[    9.759547] mlx4_core 0000:04:00.0: irq 68 for MSI/MSI-X
[    9.759555] mlx4_core 0000:04:00.0: irq 69 for MSI/MSI-X
[    9.759561] mlx4_core 0000:04:00.0: irq 70 for MSI/MSI-X
[    9.759569] mlx4_core 0000:04:00.0: irq 71 for MSI/MSI-X
[    9.759576] mlx4_core 0000:04:00.0: irq 72 for MSI/MSI-X
[    9.759583] mlx4_core 0000:04:00.0: irq 73 for MSI/MSI-X
[    9.759590] mlx4_core 0000:04:00.0: irq 74 for MSI/MSI-X
[    9.759596] mlx4_core 0000:04:00.0: irq 75 for MSI/MSI-X
[    9.759603] mlx4_core 0000:04:00.0: irq 76 for MSI/MSI-X
[    9.759611] mlx4_core 0000:04:00.0: irq 77 for MSI/MSI-X
[    9.759617] mlx4_core 0000:04:00.0: irq 78 for MSI/MSI-X
[    9.759624] mlx4_core 0000:04:00.0: irq 79 for MSI/MSI-X
[    9.759631] mlx4_core 0000:04:00.0: irq 80 for MSI/MSI-X
[    9.759638] mlx4_core 0000:04:00.0: irq 81 for MSI/MSI-X
[    9.759645] mlx4_core 0000:04:00.0: irq 82 for MSI/MSI-X
[    9.759652] mlx4_core 0000:04:00.0: irq 83 for MSI/MSI-X
[    9.759658] mlx4_core 0000:04:00.0: irq 84 for MSI/MSI-X
[    9.759666] mlx4_core 0000:04:00.0: irq 85 for MSI/MSI-X
[    9.759672] mlx4_core 0000:04:00.0: irq 86 for MSI/MSI-X
[    9.759679] mlx4_core 0000:04:00.0: irq 87 for MSI/MSI-X
[    9.759686] mlx4_core 0000:04:00.0: irq 88 for MSI/MSI-X
[    9.759692] mlx4_core 0000:04:00.0: irq 89 for MSI/MSI-X
[    9.759699] mlx4_core 0000:04:00.0: irq 90 for MSI/MSI-X
[    9.759706] mlx4_core 0000:04:00.0: irq 91 for MSI/MSI-X
[    9.759712] mlx4_core 0000:04:00.0: irq 92 for MSI/MSI-X
[    9.759720] mlx4_core 0000:04:00.0: irq 93 for MSI/MSI-X
[    9.759726] mlx4_core 0000:04:00.0: irq 94 for MSI/MSI-X
[   10.044580] mlx4_core 0000:04:00.0: SW2HW_EQ failed (-5)
[   10.058011] mlx4_core 0000:04:00.0: Failed to initialize event queue
table, aborting.
[   10.076589] mlx4_core 0000:04:00.0: PCI INT A disabled
[   10.086805] mlx4_core: probe of 0000:04:00.0 failed with error -5

