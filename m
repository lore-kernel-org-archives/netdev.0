From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx: Drain TX status before starting IRQs
Date: Wed, 01 Nov 2006 23:46:27 -0600
Message-ID: <45498633.7040808@lwfinger.net>
References: <200610191729.35402.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:39163 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1752684AbWKBFqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 00:46:44 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200610191729.35402.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> Drain the Microcode TX-status-FIFO before we enable IRQs.
> This is required, because the FIFO may still have entries left
> from a previous run. Those would immediately fire after enabling
> IRQs and would lead to an oops in the DMA TXstatus handling code.
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> 
> --
> 
> Please consider also pushing this into the -stable tree.
> The bug is not likely to trigger, but at least ben
> triggered it in the past. Anyway, it can't hurt much to
> drain the FIFO before running the device.
> 
> Note that this is diffed against 2.6.18.1 and not 2.6.18
> as the diff prolog suggests. I just forgot to rename
> the directory. ;)

Has anyone used this patch, particularly with WPA encryption? When I try it, wpa_supplicant 
immediately uses 90+% of the cpu and never actually authenticates with my AP. I wonder if it is 
something with my system.

Thanks,

Larry

