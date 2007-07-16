From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix Tsi108 ethernet driver performance
Date: Mon, 16 Jul 2007 18:27:34 -0400
Message-ID: <469BF0D6.5000601@garzik.org>
References: <1B5F013528140F45B5C671039279CA5701F834BB@NANUK.pc.tundra.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Zang Roy-r61911 <tie-fei.zang@freescale.com>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: Alexandre Bounine <Alexandre.Bounine@tundra.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37233 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169AbXGPW1h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 18:27:37 -0400
In-Reply-To: <1B5F013528140F45B5C671039279CA5701F834BB@NANUK.pc.tundra.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexandre Bounine wrote:
> From: Alexandre Bounine <alexandreb@tundra.com>
> 
> This patch improves performance of the Tsi108 Ethernet driver by
> changing interrupt handling for frame receive path. It reduces number of
> interrupts generated for received frames and therefore lowers CPU
> utilization by the device driver.
>    
> Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>

Look into NAPI...


