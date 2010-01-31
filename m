From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Sat, 30 Jan 2010 23:55:47 -0500
Message-ID: <4B650D53.2010607@majjas.com>
References: <4B61ADF1.7060705@majjas.com> <4B61BEA4.1030905@majjas.com>
 <20100128090835.0d93e53a@nehalam> <4B61DB79.4080703@majjas.com>
 <20100128223447.GC3109@del.dom.local> <4B621316.8070308@majjas.com>
 <20100128225621.GD3109@del.dom.local> <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam> <4B645EF4.4050701@majjas.com>
 <20100131003449.GA11935@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta3.srv.hcvlny.cv.net ([167.206.4.198]:45225 "EHLO
	mta3.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628Ab0AaEz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 23:55:58 -0500
In-reply-to: <20100131003449.GA11935@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/30/2010 07:34 PM, Jarek Poplawski wrote:
>
> Could you try the patch below to show maybe some other users of
> dma-debug entries?
>
> Jarek P.
> ---
>
>    
With the default # entries & dma_debug_driver=sky2:

6:00 is eth0 & 4:00 is eth1.

Jan 30 23:53:14 mail kernel: DMA-API: 0000:06:00.0: entries: 31961
Jan 30 23:53:14 mail kernel: DMA-API: 0000:00:1b.0: entries: 15
Jan 30 23:53:14 mail kernel: DMA-API: 0000:04:00.0: entries: 744
Jan 30 23:53:14 mail kernel: DMA-API: 0000:00:1f.2: entries: 6
Jan 30 23:53:14 mail kernel: DMA-API: 0000:08:01.0: entries: 3
Jan 30 23:53:14 mail kernel: DMA-API: 0000:00:1d.1: entries: 6
Jan 30 23:53:14 mail kernel: DMA-API: 0000:08:02.0: entries: 8
Jan 30 23:53:14 mail kernel: DMA-API: 0000:00:1a.7: entries: 3
Jan 30 23:53:14 mail kernel: DMA-API: 0000:00:1d.7: entries: 3
Jan 30 23:53:14 mail kernel: DMA-API: 0000:00:1a.0: entries: 3
Jan 30 23:53:14 mail kernel: DMA-API: 0000:00:1a.1: entries: 3
Jan 30 23:53:14 mail kernel: DMA-API: 0000:00:1a.2: entries: 3
Jan 30 23:53:14 mail kernel: DMA-API: 0000:00:1d.0: entries: 3
Jan 30 23:53:14 mail kernel: DMA-API: 0000:00:1d.2: entries: 3
Jan 30 23:53:14 mail kernel: DMA-API: 0000:02:00.0: entries: 1
Jan 30 23:53:14 mail kernel: DMA-API: 0000:05:00.0: entries: 2
Jan 30 23:53:14 mail kernel: DMA-API: debugging out of memory - disabling

