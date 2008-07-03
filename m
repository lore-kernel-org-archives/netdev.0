From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Thu, 03 Jul 2008 08:21:20 -0400
Message-ID: <486CC440.9030909@garzik.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org> <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53912 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752645AbYGCMV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 08:21:28 -0400
In-Reply-To: <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KOSAKI Motohiro wrote:
> Hi Michael,
> 
> my server output following error message on 2.6.26-rc8-mm1.
> Is this a bug?
> 
> ------------------------------------------------------------------
> tg3.c:v3.93 (May 22, 2008)
> GSI 72 (level, low) -> CPU 0 (0x0001) vector 51
> tg3 0000:06:01.0: PCI INT A -> GSI 72 (level, low) -> IRQ 51
> firmware: requesting tigon/tg3_tso.bin
> tg3: Failed to load firmware "tigon/tg3_tso.bin"
> tg3 0000:06:01.0: PCI INT A disabled
> GSI 72 (level, low) -> CPU 0 (0x0001) vector 51 unregistered
> tg3: probe of 0000:06:01.0 failed with error -2
> GSI 73 (level, low) -> CPU 0 (0x0001) vector 51
> tg3 0000:06:01.1: PCI INT B -> GSI 73 (level, low) -> IRQ 52
> firmware: requesting tigon/tg3_tso.bin

This change did not come from the network developers or Broadcom, so 
someone else broke tg3 in -mm...

	Jeff



