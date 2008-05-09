From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 3/3] [POWERPC] 86xx: mpc8610_hpcd: use ULI526X driver
 for	on-board ethernet
Date: Fri, 09 May 2008 13:50:58 -0500
Message-ID: <48249D12.5060307@freescale.com>
References: <20080429155333.GC28166@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:48876 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbYEISva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 14:51:30 -0400
In-Reply-To: <20080429155333.GC28166@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> As of current mainline tree, TULIP driver is unusable on MPC8610HPCD
> boards. There is a patch[1] floating around (and also included in the
> BSP), which tries to heal the situation, though the ethernet is still
> unusable. Practically it takes ages to mount NFS filesystem:

Acked-By: Timur Tabi <timur@freescale.com>

After applying this patch and Anton's two ULI driver patches, the ULI drivers
works great on an 8610HPCD.

-- 
Timur Tabi
Linux kernel developer at Freescale
