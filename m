From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] skge: fix invalid value passed to pci_unmap_sigle
Date: Sun, 22 Sep 2013 02:12:52 +0400
Message-ID: <523E19E4.20005@cogentembedded.com>
References: <alpine.LRH.2.02.1309201352010.1763@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	Igor Gnatenko <i.gnatenko.brain@gmail.com>,
	stephen@networkplumber.org
To: Mikulas Patocka <mpatocka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35142 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab3IUWMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 18:12:50 -0400
Received: by mail-lb0-f174.google.com with SMTP id w6so1604116lbh.19
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 15:12:49 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.02.1309201352010.1763@file01.intranet.prod.int.rdu2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/20/2013 09:53 PM, Mikulas Patocka wrote:

> In my patch c194992cbe71c20bb3623a566af8d11b0bfaa721 I didn't fix the skge

    Please also specify that commit's summary in parens.

> bug correctly. The value of the new mapping (not old) was passed to
> pci_unmap_single.

> If we enable CONFIG_DMA_API_DEBUG, it results in this warning:
> WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:986 check_sync+0x4c4/0x580()
> skge 0000:02:07.0: DMA-API: device driver tries to sync DMA memory it has
> not allocated [device address=0x000000023a0096c0] [size=1536 bytes]

> This patch makes the skge driver pass the correct value to
> pci_unmap_single and fixes the warning. It copies the old descriptor to
> on-stack variable "ee" and unmaps it if mapping of the new descriptor
> succeeded.

> This patch should be backported to 3.11-stable.

> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> Reported-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Mikulas Patocka <mpatocka@redhat.com>

WBR, Sergei
