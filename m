From: Christoph Lameter <cl@linux-foundation.org>
Subject: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Mon, 17 Aug 2009 15:26:02 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908171523330.20399@gentwo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:34513 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751738AbZHQT0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 15:26:10 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A07A282C847
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 15:26:15 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TpysSwb8Oxuw for <netdev@vger.kernel.org>;
	Mon, 17 Aug 2009 15:26:11 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9F25C82C83B
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 15:26:08 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx4 fails to initialize here:


[    9.973940] mlx4_core 0000:04:00.0: irq 93 for MSI/MSI-X
[    9.983108] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    9.988209] ses 0:0:32:0: Attached scsi generic sg0 type 13
[    9.999376] sd 0:2:0:0: Attached scsi generic sg1 type 0
[   10.010024] sr 1:0:0:0: Attached scsi generic sg2 type 5
[   10.256371] mlx4_core 0000:04:00.0: SW2HW_EQ failed (-5)
[   10.270103] mlx4_core 0000:04:00.0: Failed to initialize event queue
table, aborting.
[   10.288768] mlx4_core 0000:04:00.0: PCI INT A disabled
[   10.299057] mlx4_core: probe of 0000:04:00.0 failed with error -5

