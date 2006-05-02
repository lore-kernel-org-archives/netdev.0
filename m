From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/5] s2io driver updates
Date: Tue, 02 May 2006 15:16:54 -0400
Message-ID: <4457B026.10409@pobox.com>
References: <Pine.GSO.4.10.10604211900320.15266-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leonid.grossman@neterion.com,
	ravinandan.arakali@neterion.com, rapuru.sriram@neterion.com,
	alicia.pena@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:2283 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750741AbWEBTQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 15:16:57 -0400
To: Ananda Raju <Ananda.Raju@neterion.com>
In-Reply-To: <Pine.GSO.4.10.10604211900320.15266-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ananda Raju wrote:
> hi,
> 	This patch contains all the changes that were done to improve 
> 	performance of s2io driver. one line  description of the changes 
> 	are 
> 
> 	1. For Non NAPI case the rx interrupt handler is being called 
> 	   unconditionally
> 	2. code optimization and adding prefetch skb->data
> 	3. Remove modulo operations in fast path
> 	4. Enable Group Reads and set backoff interval to 0x1000
> 	5. correct PIC_CNTL_SHARED_SPLITS  macro definition, and reduce 
> 	   pause parameter
> 	6. Corrected logic of identifying rx buffer level in rx_buffer_level()
> 	7. fix DMA map and unmap done with different sizes in 1-buf mode
> 	8. Removed forcible disabling of ERO
> 	9. Send up the packets with transfer code = 0x5
> 
> Signed-off-by: Ananda Raju <ananda.raju@neterion.com>

applied 1-5 to #upstream


